import 'package:journey3_connector/journey3_connector.dart';
import 'package:journey3_connector/src/dateutil.dart';
import 'package:journey3_connector/src/domain.dart';
import 'package:journey3_connector/src/idgen.dart';
import 'package:journey3_connector/src/persistence.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:journey3_connector/src/rest.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'journey3_connector_test.mocks.dart';

const String prevSessionId = 'SESSION0';
const String sessionId = 'SESSION1';
const String accountId = 'accid';
const String appId = 'appid';
const String prevVersion = '1.0';
const String version = '2.0';
const bool releaseBuild = true;
const String clickPlay = 'click_play';
const String clickPause = 'click_pause';
const String navigate = 'navigate';
const String error = 'error';
const String crash = 'crash';
DateTime lastYear = DateTime(2021);
DateTime now = DateTime(2022);
DateTime later = DateTime(2023);

@GenerateMocks([RestApi, Persistence, Timeline, IdGenerator])
void main() {
  Logger.root.onRecord.listen((record) {
    // Uncomment to see the logging
    // print('${record.level.name}: ${record.time}: ${record.message}');
  });

  var restApi = MockRestApi();
  var persistence = MockPersistence();
  var timeline = MockTimeline();
  var idGenerator = MockIdGenerator();

  test('Report the very first session', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);

    // Act
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Verify
    verify(persistence.loadLastSession());

    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    verify(persistence.saveSession(argThat(equals(expectedSession))));

    var expectedHeader = SessionHeader(
        accountId, appId, version, releaseBuild, timeline, idGenerator);
    expectedHeader.firstLaunch = true;
    expectedHeader.firstLaunchThisHour = true;
    expectedHeader.firstLaunchToday = true;
    expectedHeader.firstLaunchThisMonth = true;
    expectedHeader.firstLaunchThisYear = true;
    expectedHeader.firstLaunchThisVersion = true;
    verify(restApi.postSessionHeader(argThat(equals(expectedHeader))));
  });

  test('Restore and report previous session', () async {
    // Setup
    var prevSession = Session(prevSessionId, accountId, appId, prevVersion,
        releaseBuild, lastYear, timeline);
    Stage stage2 = Stage(2, 'Stage 2', timeline);
    Stage stage3 = Stage(3, 'Stage 3', timeline);
    prevSession.prevStage = stage2;
    prevSession.newStage = stage3;

    when(persistence.loadLastSession())
        .thenAnswer((_) => Future.value(prevSession));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);

    // Act
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Verify
    verify(persistence.loadLastSession());

    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.prevStage = stage3;
    expectedSession.newStage = stage3;
    expectedSession.since = lastYear;

    verify(persistence.saveSession(argThat(equals(expectedSession))));

    var expectedHeader = SessionHeader(
        accountId, appId, version, releaseBuild, timeline, idGenerator);
    expectedHeader.firstLaunchThisHour = true;
    expectedHeader.firstLaunchToday = true;
    expectedHeader.firstLaunchThisMonth = true;
    expectedHeader.firstLaunchThisYear = true;
    expectedHeader.firstLaunchThisVersion = true;
    expectedHeader.prevStage = stage3;
    expectedHeader.since = lastYear;
    verify(restApi.postSessionHeader(argThat(equals(expectedHeader))));
  });

  test('Report an event', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportEvent(clickPlay);
    journey.reportEvent(clickPause);
    journey.reportEvent(clickPlay);

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.eventCounts = {clickPlay: 2, clickPause: 1};
    expectedSession.eventSequence = [clickPlay, clickPause, clickPlay];
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Report a collapsible event', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportEvent(navigate, isCollapsible: true);
    journey.reportEvent(navigate, isCollapsible: true);
    journey.reportEvent(navigate, isCollapsible: true);

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.eventCounts = {navigate: 3};
    expectedSession.eventSequence = ["($navigate)"];
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Report error', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportEvent(error, isError: true);

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.eventCounts = {error: 1};
    expectedSession.eventSequence = [error];
    expectedSession.hasError = true;
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Report crash', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportEvent(crash, isCrash: true);

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.eventCounts = {crash: 1};
    expectedSession.eventSequence = [crash];
    expectedSession.hasError = true;
    expectedSession.hasCrash = true;
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Reporting an event udpates end time', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    when(timeline.nowUtc()).thenReturn(later);
    journey.reportEvent(clickPlay);

    // Verify
    when(timeline.nowUtc()).thenReturn(now);
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.eventCounts = {clickPlay: 1};
    expectedSession.eventSequence = [clickPlay];
    expectedSession.end = later;
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Report stage transition', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportStageTransition(2, 'new_stage');

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.newStage = Stage(2, 'new_stage', timeline);
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });

  test('Report stage transition ignored when new stage is lower', () async {
    // Setup
    when(persistence.loadLastSession()).thenAnswer((_) => Future.value(null));
    when(persistence.saveSession(any)).thenAnswer((_) => Future.value(null));
    when(restApi.postSessionHeader(any)).thenAnswer((_) => Future.value(null));
    when(timeline.nowUtc()).thenReturn(now);
    when(idGenerator.newId()).thenReturn(sessionId);
    Journey journey = Journey(restApi, persistence, timeline, idGenerator);
    await journey.initialize(accountId, appId, version, releaseBuild);

    // Act
    journey.reportStageTransition(3, 'stage3');
    journey.reportStageTransition(2, 'stage2');

    // Verify
    var expectedSession = Session(
        sessionId, accountId, appId, version, releaseBuild, now, timeline);
    expectedSession.firstLaunch = true;
    expectedSession.newStage = Stage(3, 'stage3', timeline);
    verify(persistence.saveSession(argThat(equals(expectedSession))));
  });
}
