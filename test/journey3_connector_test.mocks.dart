// Mocks generated by Mockito 5.3.0 from annotations
// in journey3_connector/test/journey3_connector_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:journey3_connector/src/dateutil.dart' as _i6;
import 'package:journey3_connector/src/domain.dart' as _i4;
import 'package:journey3_connector/src/idgen.dart' as _i7;
import 'package:journey3_connector/src/persistence.dart' as _i5;
import 'package:journey3_connector/src/rest.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDateTime_0 extends _i1.SmartFake implements DateTime {
  _FakeDateTime_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [RestApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockRestApi extends _i1.Mock implements _i2.RestApi {
  MockRestApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> postSessionHeader(_i4.SessionHeader? header) =>
      (super.noSuchMethod(Invocation.method(#postSessionHeader, [header]),
              returnValue: _i3.Future<void>.value(),
              returnValueForMissingStub: _i3.Future<void>.value())
          as _i3.Future<void>);
  @override
  _i3.Future<void> postSession(_i4.Session? session) => (super.noSuchMethod(
      Invocation.method(#postSession, [session]),
      returnValue: _i3.Future<void>.value(),
      returnValueForMissingStub: _i3.Future<void>.value()) as _i3.Future<void>);
}

/// A class which mocks [Persistence].
///
/// See the documentation for Mockito's code generation for more information.
class MockPersistence extends _i1.Mock implements _i5.Persistence {
  MockPersistence() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i4.Session?> loadLastSession() =>
      (super.noSuchMethod(Invocation.method(#loadLastSession, []),
              returnValue: _i3.Future<_i4.Session?>.value())
          as _i3.Future<_i4.Session?>);
  @override
  _i3.Future<void> saveSession(_i4.Session? session) => (super.noSuchMethod(
      Invocation.method(#saveSession, [session]),
      returnValue: _i3.Future<void>.value(),
      returnValueForMissingStub: _i3.Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> removeSession() => (super.noSuchMethod(
      Invocation.method(#removeSession, []),
      returnValue: _i3.Future<void>.value(),
      returnValueForMissingStub: _i3.Future<void>.value()) as _i3.Future<void>);
}

/// A class which mocks [Timeline].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimeline extends _i1.Mock implements _i6.Timeline {
  MockTimeline() {
    _i1.throwOnMissingStub(this);
  }

  @override
  DateTime nowUtc() => (super.noSuchMethod(Invocation.method(#nowUtc, []),
          returnValue: _FakeDateTime_0(this, Invocation.method(#nowUtc, [])))
      as DateTime);
}

/// A class which mocks [IdGenerator].
///
/// See the documentation for Mockito's code generation for more information.
class MockIdGenerator extends _i1.Mock implements _i7.IdGenerator {
  MockIdGenerator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String newId() =>
      (super.noSuchMethod(Invocation.method(#newId, []), returnValue: '')
          as String);
}