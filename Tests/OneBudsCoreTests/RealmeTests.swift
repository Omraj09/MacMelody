import Foundation
import Testing
@testable import OneBudsCore
import OneBudsProtocol

@Suite struct RealmeProfileTests {
    @Test func realmeModelsMatchByNameAndProductID() {
        #expect(DeviceRegistry.match(name: "realme Buds Air8")?.id == "realme-buds-air-8")
        #expect(DeviceRegistry.match(name: "realme Buds Air 8")?.id == "realme-buds-air-8")
        #expect(DeviceRegistry.match(name: "Renamed", productID: "065812")?.id == "realme-buds-air-8")
        #expect(DeviceRegistry.match(name: "Renamed", productID: "066812")?.id == "realme-buds-air-8")
        #expect(DeviceRegistry.match(name: "realme Buds Air 8 Pro")?.id == "realme-buds-air-8-pro")
        #expect(DeviceRegistry.match(name: "realme Buds Air 5")?.id == "realme-buds-air-5")
        #expect(DeviceRegistry.match(name: "realme Buds T300")?.id == "realme-buds-t300")
        #expect(DeviceRegistry.match(name: "Renamed", productID: "062012")?.id == "realme-buds-air-5")
        #expect(DeviceRegistry.match(name: "realme Buds Air 5 Pro")?.id == "realme-buds-air-5-pro") // Unknown, not the Air 5
    }

    @Test func wireless2IsNeverControlled() throws {
        let profile = try #require(DeviceRegistry.match(name: "realme Buds Wireless 2"))
        #expect(profile.status == .unsupported)
        #expect(!profile.allowsControlSession)
    }

    @Test func realmeTriesVendorServiceThenStandardSerialPort() {
        #expect(DeviceRegistry.realmeBudsAir5.rfcommServiceUUIDs == [DeviceRegistry.opoService, DeviceRegistry.standardSPP])
        #expect(DeviceRegistry.realmeBudsAir8.rfcommServiceUUIDs == [DeviceRegistry.standardSPP, DeviceRegistry.opoService])
        #expect(DeviceRegistry.onePlusBuds3.rfcommServiceUUIDs == [DeviceRegistry.opoService])
    }

    @Test func realmePowerSavingIsNeverWritable() {
        #expect(!(DeviceRegistry.realmeBudsAir5.opo?.writableFeatureIDs.contains(0x05) ?? true))
    }

    @Test func realmeVoiceAssistantName() {
        #expect(DeviceRegistry.realmeBudsAir5.opo?.functionName(0x04) == "Voice assistant")
        #expect(DeviceRegistry.onePlusBuds3.opo?.functionName(0x03) == "Voice assistant")
    }
}

@Suite struct RealmeSessionTests {
    let air5 = DeviceRegistry.realmeBudsAir5

    func session(handler: @escaping MockTransport.Handler) async throws -> (OPOv1Session, MockTransport) {
        let transport = MockTransport(handler: handler)
        try await transport.connect()
        let session = OPOv1Session(transport: transport, profile: air5, replyTimeout: .milliseconds(150), now: { Date() })
        try await session.startSession()
        return (session, transport)
    }

    @Test func noiseLevelsUseTheRealmeTable() async throws {
        let simulator = MockEarbudsSimulator(profile: air5)
        let (session, transport) = try await session { await simulator.handle($0) }
        #expect(try await session.perform(.setNoiseControl(.noiseCancelling(.light))) == .noiseControl(.noiseCancelling(.light)))
        #expect(await transport.sentFrames.last { $0.command == 0x0404 }?.payload == [0x01, 0x01, 0x04])
        #expect(try await session.perform(.setNoiseControl(.transparency)) == .noiseControl(.transparency))
        // Plain ANC (0x08) reads back as Deep, which shares the value.
        #expect(try await session.perform(.setNoiseControl(.noiseCancelling(nil))) == .noiseControl(.noiseCancelling(.deep)))
    }

    @Test func oneByteNoiseValuesAndPushesAreAccepted() async throws {
        let simulator = MockEarbudsSimulator(profile: air5)
        let (session, transport) = try await session { data in
            if data.count > 5, data[4] == 0x0C, data[5] == 0x01 { // 0x010C read → 1-byte value, as documented for realme
                return .reply([Data(OPOFrame(command: 0x810C, sequence: data[6], payload: [0x00, 0x01, 0x01, 0x20]).encoded())])
            }
            return await simulator.handle(data)
        }
        #expect(try await session.perform(.readNoiseControl) == .noiseControl(.noiseCancelling(.smart)))
        // S12's realme T500 Pro push: AA 0B 00 00 04 02 9B 04 00 03 01 01 01 = Off.
        await transport.inject(Data([0xAA, 0x0B, 0x00, 0x00, 0x04, 0x02, 0x9B, 0x04, 0x00, 0x03, 0x01, 0x01, 0x01]))
        for await event in session.events {
            if case .noiseControl(let mode) = event { #expect(mode == .off); break }
        }
    }

    @Test func sessionStartsWithoutAHandshakeReply() async throws {
        let simulator = MockEarbudsSimulator(profile: air5)
        let (session, _) = try await session { data in
            if data.count > 5, data[4] == 0x00, data[5] == 0x01 { return .none } // ignore 0x0100
            return await simulator.handle(data)
        }
        #expect(await session.currentDeviceInfo().productID == "062012")
    }

    @Test func realmeControlByteFourIsAccepted() async throws {
        let simulator = MockEarbudsSimulator(profile: air5)
        let (session, _) = try await session { data in
            // Reply to battery with control byte 0x04 (S15 notes realme may use it).
            if data.count > 5, data[4] == 0x06, data[5] == 0x01 {
                return .reply([Data(OPOFrame(command: 0x8106, sequence: data[6], payload: [0x00, 0x02, 0x01, 0x40, 0x02, 0x41], control: 0x04).encoded())])
            }
            return await simulator.handle(data)
        }
        guard case .battery(let battery) = try await session.perform(.readBattery) else { Issue.record("no battery"); return }
        #expect(battery.left?.percent == 64 && battery.right?.percent == 65)
    }
}

private actor Air8AudioSimulator {
    var value: UInt8 = 0
    var high = false
    var eqRecord: [UInt8] = []
    let base = MockEarbudsSimulator(profile: DeviceRegistry.realmeBudsAir8)

    func handle(_ data: Data) async -> MockTransport.Reaction {
        let bytes = [UInt8](data)
        guard bytes.count > 6 else { return .none }
        let command = UInt16(bytes[4]) | UInt16(bytes[5]) << 8
        let payload: [UInt8]
        switch command {
        case 0x0201: payload = [0, bytes[9]]
        case 0x0122: payload = eqRecord.isEmpty ? [0, 0] : [0, 1] + eqRecord
        case 0x0418:
            eqRecord = bytes[9] == 3 ? [] : [1] + Array(bytes.dropFirst(10))
            payload = [0]
        case 0x0109: payload = [0, 2, 1, 3, 2, 1]
        case 0x0128: payload = [0, 1, 1, 0x78, 0x56, 0x34, 0x12]
        case 0x0400: payload = [0]
        case 0x012C: payload = [0, 1, 0xFB, 5, value, 1]
        case 0x041B:
            guard bytes.count >= 13 else { return .none }
            value = bytes[11]
            payload = [0]
        case 0x0110: payload = [0, high ? 1 : 0]
        case 0x0407:
            high = bytes[9] != 0
            payload = [0]
        default: return await base.handle(data)
        }
        return .reply([Data(OPOFrame(command: command | 0x8000, sequence: bytes[6], payload: payload).encoded())])
    }
}

@Suite struct Air8AudioTests {
    @Test func readsWritesAndChecksAudioValues() async throws {
        let simulator = Air8AudioSimulator()
        let transport = MockTransport { await simulator.handle($0) }
        try await transport.connect()
        let session = OPOv1Session(transport: transport, profile: DeviceRegistry.realmeBudsAir8, replyTimeout: .milliseconds(400), now: { Date() })
        try await session.startSession()
        guard case .dynamicAudio(let bands) = try await session.perform(.readDynamicAudio), let band = bands.first else {
            Issue.record("Missing dynamic audio band"); return
        }
        #expect(band.minimum == -5 && band.maximum == 5 && band.value == 0)
        guard case .dynamicAudio(let updated) = try await session.perform(.setDynamicAudio(band, value: -3)) else {
            Issue.record("Missing dynamic audio read-back"); return
        }
        #expect(updated.first?.value == -3)
        #expect(await transport.sentFrames.last { $0.command == 0x041B }?.payload == [0xFB, 5, 0xFD, 1])
        await #expect(throws: ProtocolError.unsupported("dynamic audio band or value")) {
            _ = try await session.perform(.setDynamicAudio(band, value: 6))
        }
        #expect(try await session.perform(.setHighVolume(true)) == .highVolume(true))
        #expect(await transport.sentFrames.last { $0.command == 0x0407 }?.payload == [1])
        #expect(try await session.perform(.readWear) == .wear([1: 3, 2: 1]))
        #expect(try await session.perform(.readListeningTime) == .listeningTime([1: 0x12345678]))
        #expect(try await session.perform(.setFindEarbuds(true)) == .findEarbuds(true))
        #expect(try await session.perform(.setFindEarbuds(false)) == .findEarbuds(false))
        #expect(await transport.sentFrames.filter { $0.command == 0x0201 }.map(\.payload) == [[1], [2], [3]])
        let custom = CustomEqualizer(id: 4, name: "Test", minimum: -6, maximum: 6, frequencies: [62, 250, 1000, 4000, 8000, 16000], levels: [-6, -2, 0, 2, 4, 6])
        #expect(try await session.perform(.saveCustomEqualizer(custom)) == .customEqualizers([custom]))
        #expect(try await session.perform(.readCustomEqualizers) == .customEqualizers([custom]))
        #expect(try await session.perform(.deleteCustomEqualizer(4)) == .customEqualizers([]))
        var invalid = custom
        invalid.levels[0] = 7
        await #expect(throws: ProtocolError.unsupported("custom equalizer values")) {
            _ = try await session.perform(.saveCustomEqualizer(invalid))
        }
    }
}
