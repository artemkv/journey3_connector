import 'package:flutter/foundation.dart';

import 'dateutil.dart';
import 'idgen.dart';

class SessionHeader {
  final Timeline timeline;
  final IdGenerator idGenerator;

  final String t = "shead";
  final String v = "1.1.0";

  final String id;
  final String accountId;
  final String appId;
  final String version;
  final bool isRelease;

  final DateTime start;
  DateTime since;

  bool firstLaunch = false;
  bool firstLaunchThisHour = false;
  bool firstLaunchToday = false;
  bool firstLaunchThisMonth = false;
  bool firstLaunchThisYear = false;
  bool firstLaunchThisVersion = false;

  Stage prevStage;

  SessionHeader(this.accountId, this.appId, this.version, this.isRelease,
      this.timeline, this.idGenerator)
      : id = idGenerator.newId(),
        start = timeline.nowUtc(),
        since = timeline.nowUtc(),
        prevStage = Stage.newUser(timeline);

  Map<String, dynamic> toJson() => {
        't': t,
        'v': v,
        'id': id,
        'since': since.toIso8601String(),
        'start': start.toIso8601String(),
        'acc': accountId,
        'aid': appId,
        'version': version,
        'is_release': isRelease,
        'fst_launch': firstLaunch,
        'fst_launch_hour': firstLaunchThisHour,
        'fst_launch_day': firstLaunchToday,
        'fst_launch_month': firstLaunchThisMonth,
        'fst_launch_year': firstLaunchThisYear,
        'fst_launch_version': firstLaunchThisVersion,
        'prev_stage': prevStage,
      };

  @override
  bool operator ==(Object other) {
    return other is SessionHeader &&
        t == other.t &&
        v == other.v &&
        id == other.id &&
        accountId == other.accountId &&
        appId == other.appId &&
        version == other.version &&
        isRelease == other.isRelease &&
        start == other.start &&
        since == other.since &&
        firstLaunch == other.firstLaunch &&
        firstLaunchThisHour == other.firstLaunchThisHour &&
        firstLaunchToday == other.firstLaunchToday &&
        firstLaunchThisMonth == other.firstLaunchThisMonth &&
        firstLaunchThisYear == other.firstLaunchThisYear &&
        firstLaunchThisVersion == other.firstLaunchThisVersion &&
        prevStage == other.prevStage;
  }

  @override
  int get hashCode {
    return Object.hashAll([t, v, id]);
  }
}

class Session {
  final Timeline timeline;

  final String t = "stail";
  final String v = "1.1.0";

  final String id;
  final String accountId;
  final String appId;
  final String version;
  final bool isRelease;

  final DateTime start;
  DateTime end;
  DateTime since;

  bool firstLaunch = false;

  Stage prevStage;
  Stage newStage;

  bool hasError = false;
  bool hasCrash = false;

  Map<String, int> eventCounts = {};
  List<String> eventSequence = [];

  Session(this.id, this.accountId, this.appId, this.version, this.isRelease,
      this.start, this.timeline)
      : end = start,
        since = start,
        prevStage = Stage.newUser(timeline),
        newStage = Stage.newUser(timeline);

  Session.fromJson(Map<String, dynamic> json, this.timeline)
      : id = json['id'] ?? uuid.v4(), // TODO: use id generator
        since =
            (json['since'] == null || DateTime.tryParse(json['since']) == null)
                ? timeline.nowUtc()
                : DateTime.tryParse(json['since'])!,
        start =
            (json['start'] == null || DateTime.tryParse(json['start']) == null)
                ? timeline.nowUtc()
                : DateTime.tryParse(json['start'])!,
        end = (json['end'] == null || DateTime.tryParse(json['end']) == null)
            ? timeline.nowUtc()
            : DateTime.tryParse(json['end'])!,
        accountId = json['acc'] ?? '',
        appId = json['aid'] ?? '',
        version = json['version'] ?? '',
        isRelease = json['is_release'] ?? false,
        firstLaunch = json['fst_launch'] ?? false,
        hasError = json['has_error'] ?? false,
        hasCrash = json['has_crash'] ?? false,
        eventCounts =
            json['evts'] != null ? json['evts'].cast<String, int>() : {},
        eventSequence =
            json['evt_seq'] != null ? json['evt_seq'].cast<String>() : [],
        prevStage = json['prev_stage'] != null
            ? Stage.fromJson(json['prev_stage'], timeline)
            : Stage.newUser(timeline),
        newStage = json['new_stage'] != null
            ? Stage.fromJson(json['new_stage'], timeline)
            : Stage.newUser(timeline);

  Map<String, dynamic> toJson() => {
        't': t,
        'v': v,
        'id': id,
        'since': since.toIso8601String(),
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'acc': accountId,
        'aid': appId,
        'version': version,
        'is_release': isRelease,
        'fst_launch': firstLaunch,
        'has_error': hasError,
        'has_crash': hasCrash,
        'evts': eventCounts,
        'evt_seq': eventSequence,
        'prev_stage': prevStage,
        'new_stage': newStage,
      };

  @override
  bool operator ==(Object other) {
    return other is Session &&
        t == other.t &&
        v == other.v &&
        id == other.id &&
        accountId == other.accountId &&
        appId == other.appId &&
        version == other.version &&
        isRelease == other.isRelease &&
        start == other.start &&
        end == other.end &&
        since == other.since &&
        firstLaunch == other.firstLaunch &&
        prevStage == other.prevStage &&
        newStage == other.newStage &&
        hasError == other.hasError &&
        hasCrash == other.hasCrash &&
        mapEquals(eventCounts, other.eventCounts) &&
        listEquals(eventSequence, other.eventSequence);
  }

  @override
  int get hashCode {
    return Object.hashAll([t, v, id]);
  }
}

class Stage {
  final Timeline timeline;

  final DateTime ts;
  final int stage;
  final String name;

  Stage(this.stage, this.name, this.timeline) : ts = timeline.nowUtc();

  Stage.newUser(this.timeline)
      : stage = 1,
        name = "new_user",
        ts = timeline.nowUtc();

  Stage.fromJson(Map<String, dynamic> json, this.timeline)
      : ts = DateTime.tryParse(json['ts']) ?? timeline.nowUtc(),
        stage = json['stage'] ?? 1,
        name = json['name'] ?? 'new_user';

  Map<String, dynamic> toJson() => {
        'ts': ts.toIso8601String(),
        'stage': stage,
        'name': name,
      };

  @override
  bool operator ==(Object other) {
    return other is Stage &&
        ts == other.ts &&
        stage == other.stage &&
        name == other.name;
  }

  @override
  int get hashCode {
    return Object.hashAll([ts, stage, name]);
  }
}

class ApiResponseError {
  final String error;

  ApiResponseError(this.error);

  ApiResponseError.fromJson(Map<String, dynamic> json) : error = json['err'];

  @override
  String toString() {
    return 'Error: $error';
  }
}
