library journey3_connector;

import 'package:logging/logging.dart';

import 'domain.dart';
import 'rest.dart';
import 'dateutil.dart';
import 'persistence.dart';

const maxSeqLength = 100;

final log = Logger('Journey');
Journey journey = Journey();

class Journey {
  Session? currentSession;

  static Journey instance() {
    return journey;
  }

  /// Initializes new session.
  /// [accountId] is your account id
  /// [appId] is your application id
  /// [version] is the application version (e.g. 1.2.3)
  /// Use packageInfo.version to access version.
  /// [isRelease] is to separate debug sessions from release sessions.
  /// Use kReleaseMode to access mode.
  Future<void> initialize(
      String accountId, String appId, String version, bool isRelease) async {
    try {
      // start new session
      var header = SessionHeader(accountId, appId, version, isRelease);
      currentSession = Session(
          header.id, accountId, appId, version, isRelease, header.start);
      log.info('Journey3: Started new session ${currentSession!.id}');

      // report previous session
      final session = await loadLastSession();
      if (session != null) {
        log.info('Journey3: Report the end of the previous session');
        await postSession(session);
      }

      // update current session based on the previous one
      if (session == null) {
        header.firstLaunch = true;
        currentSession!.firstLaunch = true;

        header.firstLaunchThisHour = true;
        header.firstLaunchToday = true;
        header.firstLaunchThisMonth = true;
        header.firstLaunchThisYear = true;
        header.firstLaunchThisVersion = true;
      } else {
        var today = DateTime.now().toUtc();
        var lastSessionStart = session.start;

        if (!lastSessionStart.isSameHour(today)) {
          header.firstLaunchThisHour = true;
        }
        if (!lastSessionStart.isSameDay(today)) {
          header.firstLaunchToday = true;
        }
        if (!lastSessionStart.isSameMonth(today)) {
          header.firstLaunchThisMonth = true;
        }
        if (!lastSessionStart.isSameYear(today)) {
          header.firstLaunchThisYear = true;
        }
        if (session.version != version) {
          header.firstLaunchThisVersion = true;
        }

        currentSession!.prevStage = session.newStage;
        currentSession!.newStage = session.newStage;
        header.prevStage = session.newStage;

        header.since = session.since;
        currentSession!.since = session.since;
      }

      // save current session
      await saveSession(currentSession!);

      // report the new session (header)
      log.info('Journey3: Report the start of a new session');
      await postSessionHeader(header);
    } catch (err) {
      log.warning('Journey3: Failed to initialize Journey: ${err.toString()}');
    }
  }

  /// Registers the event in the current session.
  ///
  /// Events are distinguished by [eventName], for example 'click_play',
  /// 'add_to_library' or 'use_search'.
  /// Short and clear names are recommended.
  ///
  /// Do not include any personal data as an event name.
  ///
  /// Specify whether event [isCollapsible].
  /// Collapsible events will only appear in the sequence once.
  /// Make events collapsible when number of times it is repeated is not
  /// important. For example, if your application is music play app, where the
  /// users normally browse through the list of albums before clicking 'play',
  /// 'scroll_to_next_album' event would probably be a good candidate to be
  /// made collapsible, while 'click_play' event would probably not.
  ///
  /// Collapsible event names appear in brackets in the sequence,
  /// for example '(scroll_to_next_album)'.
  Future<void> reportEvent(String eventName,
      {bool isCollapsible = false,
      bool isError = false,
      bool isCrash = false}) async {
    if (currentSession == null) {
      log.warning(
          'Journey3: Cannot update session. Journey have not been initialized.');
      return;
    }

    try {
      // count events
      currentSession!.eventCounts[eventName] =
          (currentSession!.eventCounts[eventName] ?? 0) + 1;

      // set error
      if (isError) {
        currentSession!.hasError = true;
      }
      if (isCrash) {
        currentSession!.hasCrash = true;
      }

      // sequence events
      var seq = currentSession!.eventSequence;
      if (seq.length < maxSeqLength) {
        var seqEventName = isCollapsible ? '($eventName)' : eventName;
        if (!(seq.isNotEmpty && seq.last == seqEventName && isCollapsible)) {
          seq.add(seqEventName);
        } else {
          // ignore the event for the sequence
        }
      }

      // update endtime
      currentSession!.end = DateTime.now().toUtc();

      // save session
      await saveSession(currentSession!);
    } catch (err) {
      log.warning('Journey3: Cannot update session: ${err.toString()}');
    }
  }

  /// Reports the stage transition, e.g. 'engagement', 'checkout', 'payment'.
  /// Stage transitions are used to build funnels.
  ///
  /// [stage] is an ordinal number [1..10] that defines the stage.
  /// Stage transitions must be increasing. If the current session is already
  /// at the higher stage, the call will be ignored.
  /// This means you don't need to keep track of a current stage.
  ///
  /// [stageName] provides the stage name for informational purposes.
  ///
  /// It is recommended to define stages upfront as the numbers used to build
  /// conversion funnel.
  /// If you sumbit the new name for the same stage, that new name will be used
  /// in all future reports.
  Future<void> reportStageTransition(int stage, String stageName) async {
    if (currentSession == null) {
      log.warning(
          'Journey3: Cannot update stage. Journey have not been initialized.');
      return;
    }

    if (stage < 1 || stage > 10) {
      throw Exception(
          'Invalid value $stage for stage, must be between 1 and 10');
    }

    try {
      if (currentSession!.newStage.stage < stage) {
        currentSession!.newStage = Stage(stage, stageName);
      }

      // save session
      await saveSession(currentSession!);
    } catch (err) {
      log.warning('Journey3: Cannot update session: ${err.toString()}');
    }
  }
}
