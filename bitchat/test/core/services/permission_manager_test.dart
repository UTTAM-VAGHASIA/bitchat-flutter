import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:bitchat/core/services/permission_manager.dart';
import 'package:bitchat/core/services/platform_service.dart';
import 'package:bitchat/core/models/permission.dart';
import 'package:bitchat/core/models/platform_info.dart';
import 'package:bitchat/core/models/platform_event.dart';

import 'permission_manager_test.mocks.dart';

@GenerateMocks([PlatformService])
void main() {
  group('PermissionManager', () {
    late MockPlatformService mockPlatformService;
    late StreamController<PlatformEvent> platformEventController;
    late PermissionManager permissionManager;

    setUp(() {
      mockPlatformService = MockPlatformService();
      platformEventController = StreamController<PlatformEvent>.broadcast();

      // Setup default mock behavior
      when(
        mockPlatformService.platformEvents,
      ).thenAnswer((_) => platformEventController.stream);

      when(mockPlatformService.getPlatformInfo()).thenAnswer(
        (_) async => const PlatformInfo(
          type: PlatformType.android,
          version: 'Android 14',
          deviceModel: 'Test Device',
          capabilities: [
            PlatformCapability.bluetooth,
            PlatformCapability.bluetoothLowEnergy,
            PlatformCapability.bluetoothAdvertising,
            PlatformCapability.bluetoothScanning,
            PlatformCapability.locationServices,
            PlatformCapability.notifications,
          ],
          performance: PerformanceProfile.medium,
        ),
      );

      when(
        mockPlatformService.getPermissionStatus(any),
      ).thenAnswer((_) async => <Permission, PermissionStatus>{});
    });

    tearDown(() async {
      await platformEventController.close();
      await permissionManager.dispose();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockPlatformService.getPermissionStatus(any)).thenAnswer(
          (_) async => <Permission, PermissionStatus>{
            Permission.bluetooth: PermissionStatus.granted,
            Permission.location: PermissionStatus.denied,
          },
        );

        // Act
        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await permissionManager.refreshPermissionCacheForTesting();

        // Assert
        expect(permissionManager, isNotNull);
        verify(mockPlatformService.getPlatformInfo()).called(1);
        verify(mockPlatformService.getPermissionStatus(any)).called(1);
      });

      test(
        'should handle platform info initialization failure gracefully',
        () async {
          // Arrange
          when(
            mockPlatformService.getPlatformInfo(),
          ).thenThrow(Exception('Platform info failed'));
          when(
            mockPlatformService.getPermissionStatus(any),
          ).thenAnswer((_) async => <Permission, PermissionStatus>{});

          // Act & Assert
          expect(() async {
            permissionManager = PermissionManager.forTesting(
              platformService: mockPlatformService,
            );
            await Future.delayed(
              Duration(milliseconds: 100),
            ); // Allow initialization
          }, returnsNormally);
        },
      );
    });

    group('getRequiredPermissions', () {
      test('should return Android permissions for Android platform', () async {
        // Arrange
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization

        // Act
        final permissions = permissionManager.getRequiredPermissions();

        // Assert
        expect(permissions, contains(Permission.bluetooth));
        expect(permissions, contains(Permission.bluetoothAdvertise));
        expect(permissions, contains(Permission.bluetoothConnect));
        expect(permissions, contains(Permission.bluetoothScan));
        expect(permissions, contains(Permission.location));
        expect(permissions, contains(Permission.notification));
      });

      test('should return iOS permissions for iOS platform', () async {
        // Arrange
        when(mockPlatformService.getPlatformInfo()).thenAnswer(
          (_) async => const PlatformInfo(
            type: PlatformType.ios,
            version: 'iOS 17.0',
            deviceModel: 'iPhone 15',
            capabilities: [
              PlatformCapability.bluetooth,
              PlatformCapability.bluetoothLowEnergy,
              PlatformCapability.notifications,
            ],
            performance: PerformanceProfile.high,
          ),
        );
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization

        // Act
        final permissions = permissionManager.getRequiredPermissions();

        // Assert
        expect(permissions, contains(Permission.bluetooth));
        expect(permissions, contains(Permission.notification));
        expect(permissions, isNot(contains(Permission.location)));
      });

      test(
        'should return default permissions when platform info is unavailable',
        () {
          // Arrange
          permissionManager = PermissionManager.forTesting(
            platformService: mockPlatformService,
          );
          // Don't wait for initialization to complete

          // Act
          final permissions = permissionManager.getRequiredPermissions();

          // Assert
          expect(permissions, contains(Permission.bluetooth));
          expect(permissions, contains(Permission.notification));
        },
      );
    });

    group('getCriticalPermissions', () {
      test('should return only critical permissions', () async {
        // Arrange
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization

        // Act
        final permissions = permissionManager.getCriticalPermissions();

        // Assert
        for (final permission in permissions) {
          expect(permission.isCritical, isTrue);
        }
      });
    });

    group('requestPermissions', () {
      setUp(() async {
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization
      });

      test(
        'should request permissions successfully when all are granted',
        () async {
          // Arrange
          final permissions = [Permission.bluetooth, Permission.notification];

          // Setup mock to return denied status initially, then granted after request
          var callCount = 0;
          when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer(
            (_) async {
              callCount++;
              if (callCount == 1) {
                // First call - initial status check
                return {
                  Permission.bluetooth: PermissionStatus.denied,
                  Permission.notification: PermissionStatus.denied,
                };
              } else {
                // Second call - after permission request
                return {
                  Permission.bluetooth: PermissionStatus.granted,
                  Permission.notification: PermissionStatus.granted,
                };
              }
            },
          );

          when(
            mockPlatformService.requestPermissions(permissions),
          ).thenAnswer((_) async => true);

          // Act
          final result = await permissionManager.requestPermissions(
            permissions,
          );

          // Assert
          expect(result.allGranted, isTrue);
          expect(result.granted, containsAll(permissions));
          expect(result.denied, isEmpty);
          expect(result.requiresSettings, isEmpty);
          expect(result.error, isNull);

          verify(mockPlatformService.requestPermissions(any)).called(1);
        },
      );

      test('should handle partially granted permissions', () async {
        // Arrange
        final permissions = [Permission.bluetooth, Permission.notification];

        // Setup mock to return denied status initially, then partially granted after request
        var callCount = 0;
        when(mockPlatformService.getPermissionStatus(any)).thenAnswer((
          invocation,
        ) async {
          callCount++;
          final requestedPermissions =
              invocation.positionalArguments[0] as List<Permission>;
          print(
            'getPermissionStatus call $callCount with permissions: $requestedPermissions',
          );

          if (callCount == 1) {
            // First call - initial status check
            final result = <Permission, PermissionStatus>{};
            for (final permission in requestedPermissions) {
              result[permission] = PermissionStatus.denied;
            }
            print('Returning denied status: $result');
            return result;
          } else {
            // Second call - after permission request (partially granted)
            final result = <Permission, PermissionStatus>{};
            for (final permission in requestedPermissions) {
              if (permission == Permission.bluetooth) {
                result[permission] = PermissionStatus.granted;
              } else {
                result[permission] = PermissionStatus.denied;
              }
            }
            print('Returning partially granted status: $result');
            return result;
          }
        });

        when(
          mockPlatformService.requestPermissions(any),
        ).thenAnswer((_) async => false);

        // Act
        final result = await permissionManager.requestPermissions(
          permissions,
          config: PermissionRequestConfig(retryOnFailure: false, maxRetries: 0),
        );

        // Assert
        expect(result.allGranted, isFalse);
        expect(result.granted, contains(Permission.bluetooth));
        expect(result.denied, contains(Permission.notification));
      });

      test('should handle permanently denied permissions', () async {
        // Arrange
        final permissions = [Permission.bluetooth];

        when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer(
          (_) async => {
            Permission.bluetooth: PermissionStatus.permanentlyDenied,
          },
        );

        // Act
        final result = await permissionManager.requestPermissions(permissions);

        // Assert
        expect(result.allGranted, isFalse);
        expect(result.requiresSettings, contains(Permission.bluetooth));

        // Should not attempt to request permanently denied permissions
        verifyNever(mockPlatformService.requestPermissions(any));
      });

      test('should handle already granted permissions', () async {
        // Arrange
        final permissions = [Permission.bluetooth, Permission.notification];

        when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer(
          (_) async => {
            Permission.bluetooth: PermissionStatus.granted,
            Permission.notification: PermissionStatus.granted,
          },
        );

        // Act
        final result = await permissionManager.requestPermissions(permissions);

        // Assert
        expect(result.allGranted, isTrue);
        expect(result.granted, containsAll(permissions));

        // Should not attempt to request already granted permissions
        verifyNever(mockPlatformService.requestPermissions(any));
      });

      test('should handle request timeout', () async {
        // Arrange
        final permissions = [Permission.bluetooth];
        final config = PermissionRequestConfig(timeoutSeconds: 1);

        when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer(
          (_) async => {Permission.bluetooth: PermissionStatus.denied},
        );

        // Simulate a long-running request
        when(mockPlatformService.requestPermissions(permissions)).thenAnswer((
          _,
        ) async {
          await Future.delayed(Duration(seconds: 2));
          return true;
        });

        // Act
        final result = await permissionManager.requestPermissions(
          permissions,
          config: config,
        );

        // Assert
        expect(result.allGranted, isFalse);
        expect(result.error, contains('timed out'));
      });

      test('should retry on failure when configured', () async {
        // Arrange
        final permissions = [Permission.bluetooth];
        final config = PermissionRequestConfig(
          retryOnFailure: true,
          maxRetries: 2,
        );

        // Setup mock for permission status calls
        var statusCallCount = 0;
        when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer((
          _,
        ) async {
          statusCallCount++;
          if (statusCallCount == 1) {
            // Initial status check - denied
            return {Permission.bluetooth: PermissionStatus.denied};
          } else {
            // Final status check - granted after retries
            return {Permission.bluetooth: PermissionStatus.granted};
          }
        });

        // First two calls fail, third succeeds
        var requestCallCount = 0;
        when(mockPlatformService.requestPermissions(permissions)).thenAnswer((
          _,
        ) async {
          requestCallCount++;
          return requestCallCount >= 3;
        });

        // Act
        final result = await permissionManager.requestPermissions(
          permissions,
          config: config,
        );

        // Assert
        expect(result.allGranted, isTrue);
        verify(mockPlatformService.requestPermissions(any)).called(3);
      });

      test('should handle platform service errors gracefully', () async {
        // Arrange
        final permissions = [Permission.bluetooth];

        when(
          mockPlatformService.getPermissionStatus(permissions),
        ).thenThrow(Exception('Platform service error'));

        // Act
        final result = await permissionManager.requestPermissions(permissions);

        // Assert
        // The PermissionManager should be resilient and return cached/unknown values
        // rather than failing completely when the platform service has errors
        expect(result.allGranted, isFalse);
        expect(
          result.error,
          isNull,
        ); // Should not fail, but use cached/unknown values
        expect(
          result.denied,
          contains(Permission.bluetooth),
        ); // Should be denied/unknown
      });

      test('should return failure when disposed', () async {
        // Arrange
        final permissions = [Permission.bluetooth];
        await permissionManager.dispose();

        // Act
        final result = await permissionManager.requestPermissions(permissions);

        // Assert
        expect(result.allGranted, isFalse);
        expect(result.error, contains('disposed'));
      });
    });

    group('getPermissionStatus', () {
      setUp(() async {
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization
      });

      test('should return current permission status', () async {
        // Arrange
        final permissions = [Permission.bluetooth, Permission.notification];
        final expectedStatus = {
          Permission.bluetooth: PermissionStatus.granted,
          Permission.notification: PermissionStatus.denied,
        };

        when(
          mockPlatformService.getPermissionStatus(permissions),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        final result = await permissionManager.getPermissionStatus(permissions);

        // Assert
        expect(result, equals(expectedStatus));
        verify(mockPlatformService.getPermissionStatus(permissions)).called(1);
      });

      test('should return cached values on platform service error', () async {
        // Arrange
        final permissions = [Permission.bluetooth];

        // First call succeeds and caches the value
        when(mockPlatformService.getPermissionStatus(permissions)).thenAnswer(
          (_) async => {Permission.bluetooth: PermissionStatus.granted},
        );

        await permissionManager.getPermissionStatus(permissions);

        // Second call fails
        when(
          mockPlatformService.getPermissionStatus(permissions),
        ).thenThrow(Exception('Platform service error'));

        // Act
        final result = await permissionManager.getPermissionStatus(permissions);

        // Assert
        expect(result[Permission.bluetooth], equals(PermissionStatus.granted));
      });

      test('should return empty map when disposed', () async {
        // Arrange
        final permissions = [Permission.bluetooth];
        await permissionManager.dispose();

        // Act
        final result = await permissionManager.getPermissionStatus(permissions);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('permission change events', () {
      setUp(() async {
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization
      });

      test('should forward permission change events', () async {
        // Arrange
        final event = PermissionChangedEvent(
          permission: Permission.bluetooth,
          status: PermissionStatus.granted,
          previousStatus: PermissionStatus.denied,
          timestamp: DateTime.now(),
        );

        // Act
        platformEventController.add(event);

        // Assert
        await expectLater(permissionManager.permissionChanges, emits(event));
      });

      test('should update cache when permission changes', () async {
        // Arrange
        final event = PermissionChangedEvent(
          permission: Permission.bluetooth,
          status: PermissionStatus.granted,
          timestamp: DateTime.now(),
        );

        // Act
        platformEventController.add(event);
        await Future.delayed(
          Duration(milliseconds: 10),
        ); // Allow event processing

        // Get status to check cache
        when(
          mockPlatformService.getPermissionStatus([Permission.bluetooth]),
        ).thenThrow(Exception('Should use cache'));

        final result = await permissionManager.getPermissionStatus([
          Permission.bluetooth,
        ]);

        // Assert
        expect(result[Permission.bluetooth], equals(PermissionStatus.granted));
      });
    });

    group('convenience methods', () {
      setUp(() async {
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization
      });

      test(
        'areRequiredPermissionsGranted should return true when all granted',
        () async {
          // Arrange
          when(mockPlatformService.getPermissionStatus(any)).thenAnswer(
            (_) async => {
              Permission.bluetooth: PermissionStatus.granted,
              Permission.bluetoothAdvertise: PermissionStatus.granted,
              Permission.bluetoothConnect: PermissionStatus.granted,
              Permission.bluetoothScan: PermissionStatus.granted,
              Permission.location: PermissionStatus.granted,
              Permission.notification: PermissionStatus.granted,
            },
          );

          // Act
          final result = await permissionManager
              .areRequiredPermissionsGranted();

          // Assert
          expect(result, isTrue);
        },
      );

      test(
        'areRequiredPermissionsGranted should return false when any denied',
        () async {
          // Arrange
          when(mockPlatformService.getPermissionStatus(any)).thenAnswer(
            (_) async => {
              Permission.bluetooth: PermissionStatus.granted,
              Permission.bluetoothAdvertise: PermissionStatus.denied,
              Permission.bluetoothConnect: PermissionStatus.granted,
              Permission.bluetoothScan: PermissionStatus.granted,
              Permission.location: PermissionStatus.granted,
              Permission.notification: PermissionStatus.granted,
            },
          );

          // Act
          final result = await permissionManager
              .areRequiredPermissionsGranted();

          // Assert
          expect(result, isFalse);
        },
      );

      test(
        'areCriticalPermissionsGranted should check only critical permissions',
        () async {
          // Arrange
          // Mock the permission status to return granted for all critical permissions
          // and denied for non-critical ones
          when(mockPlatformService.getPermissionStatus(any)).thenAnswer((
            invocation,
          ) async {
            final permissions =
                invocation.positionalArguments[0] as List<Permission>;
            final result = <Permission, PermissionStatus>{};

            for (final permission in permissions) {
              if (permission.isCritical) {
                result[permission] = PermissionStatus.granted;
              } else {
                result[permission] = PermissionStatus.denied;
              }
            }

            return result;
          });

          // Act
          final result = await permissionManager
              .areCriticalPermissionsGranted();

          // Assert
          expect(
            result,
            isTrue,
          ); // Should be true since all critical permissions are granted
        },
      );
    });

    group('dispose', () {
      test('should dispose cleanly', () async {
        // Arrange
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization

        // Act
        await permissionManager.dispose();

        // Assert
        expect(() => permissionManager.dispose(), returnsNormally);
      });

      test('should handle multiple dispose calls', () async {
        // Arrange
        when(
          mockPlatformService.getPermissionStatus(any),
        ).thenAnswer((_) async => <Permission, PermissionStatus>{});

        permissionManager = PermissionManager.forTesting(
          platformService: mockPlatformService,
        );
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Allow initialization

        // Act & Assert
        await permissionManager.dispose();
        await permissionManager.dispose(); // Should not throw
      });
    });
  });
}
