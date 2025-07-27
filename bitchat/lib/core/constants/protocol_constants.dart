/// Protocol-specific constants for BitChat mesh networking
class ProtocolConstants {
  // Message Types
  static const int messageTypeText = 0x01;
  static const int messageTypeJoin = 0x02;
  static const int messageTypePart = 0x03;
  static const int messageTypeWho = 0x04;
  static const int messageTypePrivate = 0x05;
  static const int messageTypeAck = 0x06;
  static const int messageTypeDiscovery = 0x07;
  static const int messageTypeHeartbeat = 0x08;

  // Protocol Version
  static const int protocolVersion = 2;
  static const int minSupportedVersion = 1;

  // Bluetooth Constants
  static const String serviceUuid = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String characteristicUuid =
      '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String deviceNamePrefix = 'BitChat';

  // Network Topology
  static const int maxPeersPerNode = 8;
  static const int maxChannelsPerPeer = 16;
  static const Duration peerTimeout = Duration(minutes: 5);
  static const Duration heartbeatInterval = Duration(seconds: 30);

  // Message Routing
  static const int maxRetransmissions = 3;
  static const Duration retransmissionDelay = Duration(seconds: 2);
  static const int routingTableSize = 256;

  // Encryption
  static const int keySize = 32; // 256 bits
  static const int nonceSize = 12; // 96 bits for AES-GCM
  static const int tagSize = 16; // 128 bits for AES-GCM
  static const Duration keyRotationInterval = Duration(hours: 24);

  // Channel Constants
  static const String defaultChannel = '#general';
  static const int maxChannelNameLength = 32;
  static const int maxUsernameLength = 16;
  static const int maxMessageLength = 512;

  // Private constructor to prevent instantiation
  ProtocolConstants._();
}
