init() Error:Error Domain=NSOSStatusErrorDomain Code=-50 "(null)"
2018-05-19 19:43:08.147067-0700 MuseNow WatchKit Extension[203:6041] [default] -[SPInterfaceViewController performBlockOnViewDidAppear:]:1258: Tried to set _didAppearBlock but we already have one! <SPInterfaceViewController: 0x18914600>
7:43:08.867: ⧉ unarchiveSettings
7:43:08.852: ↔︎ session(_:activationDidCompleteWith:error:) state:WCSessionActivationState
7:43:08.915: ⧉ unarchiveData:Settings.json memoryTime:1526783249.0 count:80 bytes
7:43:08.936: ⧉ Settings::settingsFromRoot() saySet:7
7:43:08.964: ⧉ unarchiveData:Memos.json count:0
7:43:09.455: ⧉ unarchiveData:Routine.json count:0
7:43:09.465: ⧉ Routine::makeDemoRoutine()
7:43:10.000: → cacheMsg FileMsg [nameTimes:["Settings.json": 1526783249.0]]
7:43:10.231: ⧉ unarchiveData:Marks.json count:0
7:43:10.290: ⧉ unarchiveData:Calendars.json count:0
7:43:10.453: → cacheMsg FileMsg [nameTimes:["Settings.json": 1526783249.0]]

startup

7:44:32.144: ⧉ unarchiveData:Menu.json count:0
7:44:32.180: ⧉ saveData Menu.json 0.0 ➛ 1526784272.0 𝚫1526784272.0
7:44:32.741: ⧉ unarchiveData:Menu.json memoryTime:1526784272.0 count:531 bytes
7:44:32.773: ⧉ saveData Menu.json No Change 𝚫0.0
7:44:33.320: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526783249.0]]

menu

7:44:49.965: ⧉ saveData Routine.json 0.0 ➛ 1526784289.0 𝚫1526784289.0
7:44:50.007: ⧉ unarchiveSettings
7:44:50.024: ⧉ unarchiveData:Settings.json memoryTime:1526783249.0 count:80 bytes
7:44:50.029: ⧉ Settings::settingsFromRoot() saySet:7
7:44:50.088: ⧉ unarchiveData:Memos.json count:0
7:44:50.122: ⧉ unarchiveData:Marks.json count:0
7:44:50.229: ⧉ unarchiveData:Calendars.json count:0
7:44:51.002: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526783249.0, "Routine.json": 1526784289.0]]
rest off
7:45:11.998: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526783249.0, "Routine.json": 1526784289.0]]
dial ok
7:45:44.592: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784272, getFile:Menu.json]
7:45:44.663: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784289, getFile:Routine.json]
7:45:44.716: ⧉ sendPostFile fileName:Routine.json fileTime:1526784289.0
7:45:44.729: → cacheMsg FileMsg [fileTime:1526784289.0, data:<data>, postFile:Routine.json]
7:45:45.430: ← session(_:didReceiveApplicationContext:) FileMsg [nameTimes:{
    "Settings.json" = 1526784344;
}]
7:45:45.462: → cacheMsg FileMsg [getFile:Settings.json, fileTime:1526784344.0]
7:45:45.759: ← recvMsg: ShowSet [putSet:63]
7:45:45.769: ⧉ saveData Settings.json 1526783249.0 ➛ 1526784345.0 𝚫1096.0
7:45:45.795: ⧉ saveData Settings.json No Change 𝚫0.0
7:45:46.093: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784344, data:<data>, postFile:Settings.json]
7:45:46.801: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784345.0, "Routine.json": 1526784289.0]]
7:45:47.107: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784289, getFile:Routine.json]
7:45:47.154: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784345, getFile:Settings.json]
7:45:47.185: ← session(_:didReceiveApplicationContext:) FileMsg [nameTimes:{
    "Menu.json" = 1526784345;
    "Settings.json" = 1526784344;
}]
7:45:47.201: → cacheMsg FileMsg [getFile:Menu.json, fileTime:1526784345.0]
7:45:50.253: ⧉ unarchiveSettings
7:45:50.269: ⧉ unarchiveData:Settings.json memoryTime:1526784345.0 count:80 bytes
7:45:50.274: ⧉ Settings::settingsFromRoot() saySet:7
7:45:50.295: ⧉ sendPostFile fileName:Routine.json fileTime:1526784289.0
7:45:50.298: ⧉ sendPostFile fileName:Settings.json fileTime:1526784345.0
7:45:50.310: → cacheMsg FileMsg [fileTime:1526784289.0, data:<data>, postFile:Routine.json]
7:45:50.315: → cacheMsg FileMsg [fileTime:1526784345.0, data:<data>, postFile:Settings.json]
7:45:50.325: ⧉ saveData Settings.json No Change 𝚫-1.0
7:45:50.327: ⧉ sendPostFile fileName:Settings.json fileTime:1526784345.0
7:45:50.333: → cacheMsg FileMsg [fileTime:1526784345.0, data:<data>, postFile:Settings.json]
7:45:50.346: ⧉ unarchiveData:Memos.json count:0
7:45:50.349: ⧉ Routine::makeDemoRoutine()
7:45:50.513: ⧉ unarchiveData:Calendars.json count:0
7:45:50.529: ⧉ unarchiveData:Marks.json count:0
start phone - watch reverted back
7:46:24.901: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784345.0, "Routine.json": 1526784289.0]]
7:46:30.790: ← recvMsg: ShowSet [putSet:7]
7:46:30.806: ⧉ saveData Settings.json 1526784345.0 ➛ 1526784390.0 𝚫45.0
7:46:30.830: ⧉ saveData Settings.json No Change 𝚫0.0
7:46:31.832: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784390.0, "Routine.json": 1526784289.0]]
7:46:31.871: ← session(_:didReceiveApplicationContext:) FileMsg [nameTimes:{
    "Menu.json" = 1526784345;
    "Routine.json" = 1526784289;
    "Settings.json" = 1526784390;
}]
7:46:31.897: → cacheMsg FileMsg [getFile:Menu.json, fileTime:1526784345.0]
7:46:32.306: ⧉ unarchiveSettings
7:46:32.321: ⧉ unarchiveData:Settings.json memoryTime:1526784390.0 count:79 bytes
7:46:32.329: ⧉ Settings::settingsFromRoot() saySet:7
7:46:32.361: ⧉ unarchiveData:Memos.json count:0
7:46:32.383: ⧉ unarchiveData:Marks.json count:0
7:46:32.553: ⧉ unarchiveData:Calendars.json count:0

phone routine off - watch routine off

7:47:02.998: ← recvMsg: ShowSet [putSet:15]
7:47:03.015: ⧉ saveData Settings.json 1526784390.0 ➛ 1526784423.0 𝚫33.0
7:47:03.043: ⧉ saveData Settings.json No Change 𝚫0.0
7:47:03.049: ⧉ unarchiveSettings
7:47:03.063: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
7:47:03.069: ⧉ Settings::settingsFromRoot() saySet:7
7:47:03.125: ⧉ unarchiveData:Memos.json count:0
7:47:03.155: ⧉ unarchiveData:Marks.json count:0
7:47:03.239: ⧉ unarchiveData:Calendars.json count:0
7:47:04.045: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784289.0]]
7:47:04.138: ← session(_:didReceiveApplicationContext:) FileMsg [nameTimes:{
    "Menu.json" = 1526784345;
    "Routine.json" = 1526784289;
    "Settings.json" = 1526784422;
}]
7:47:04.160: → cacheMsg FileMsg [getFile:Menu.json, fileTime:1526784345.0]
7:47:04.276: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784423, getFile:Settings.json]
7:47:09.295: ⧉ sendPostFile fileName:Settings.json fileTime:1526784423.0
7:47:09.297: ⧉ sendPostFile fileName:Settings.json fileTime:1526784423.0
7:47:09.310: → cacheMsg FileMsg [fileTime:1526784423.0, data:<data>, postFile:Settings.json]
7:47:09.321: → cacheMsg FileMsg [fileTime:1526784423.0, data:<data>, postFile:Settings.json]

phone routine on - watch routine on

7:47:26.102: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784289.0]]
touches !moved pos:(187.0, 204.0) distance:39.2046
watch menu routine.rest unchecked
7:48:21.025: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784289.0]]
dial - incorrect rest is still on
touches !moved pos:(-2.0, 148.0) distance:9.21954
touches !moved pos:(-2.0, 148.0) distance:9.21954
touches !moved pos:(249.0, 161.0) distance:16.1245
7:49:10.092: ← session(_:didReceiveApplicationContext:) FileMsg [nameTimes:{
    "Menu.json" = 1526784345;
    "Routine.json" = 1526784289;
    "Settings.json" = 1526784423;
}]
7:49:10.103: → cacheMsg FileMsg [getFile:Menu.json, fileTime:1526784345.0]

phone  on

7:49:27.285: ⧉ saveData Routine.json 1526784289.0 ➛ 1526784567.0 𝚫278.0
7:49:27.308: ⧉ unarchiveSettings
7:49:27.316: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
7:49:27.320: ⧉ Settings::settingsFromRoot() saySet:7
7:49:27.342: ⧉ unarchiveData:Memos.json count:0
7:49:27.405: ⧉ unarchiveData:Marks.json count:0
7:49:27.507: ⧉ unarchiveData:Calendars.json count:0
7:49:28.309: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784567.0]]
7:49:28.485: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784567, getFile:Routine.json]
7:49:28.519: ⧉ sendPostFile fileName:Routine.json fileTime:1526784567.0
7:49:28.526: → cacheMsg FileMsg [fileTime:1526784567.0, data:<data>, postFile:Routine.json]

rest on

7:49:39.828: ⧉ saveData Routine.json 1526784567.0 ➛ 1526784579.0 𝚫12.0
7:49:39.852: ⧉ unarchiveSettings
7:49:39.859: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
7:49:39.864: ⧉ Settings::settingsFromRoot() saySet:7
7:49:39.882: ⧉ unarchiveData:Memos.json count:0
7:49:40.019: ⧉ unarchiveData:Marks.json count:0
7:49:40.086: ⧉ unarchiveData:Calendars.json count:0
7:49:40.854: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784579.0]]
7:49:41.080: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784579, getFile:Routine.json]
7:49:41.112: ⧉ sendPostFile fileName:Routine.json fileTime:1526784579.0
7:49:41.119: → cacheMsg FileMsg [fileTime:1526784579.0, data:<data>, postFile:Routine.json]

rest off - no change on phone

7:50:03.316: ⧉ saveData Routine.json 1526784579.0 ➛ 1526784603.0 𝚫24.0
7:50:03.333: ⧉ unarchiveSettings
7:50:03.342: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
7:50:03.346: ⧉ Settings::settingsFromRoot() saySet:7
7:50:03.384: ⧉ unarchiveData:Memos.json count:0
7:50:03.462: ⧉ unarchiveData:Marks.json count:0
7:50:03.513: ⧉ unarchiveData:Calendars.json count:0
7:50:04.336: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784603.0]]
7:50:04.527: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784603, getFile:Routine.json]
7:50:04.557: ⧉ sendPostFile fileName:Routine.json fileTime:1526784603.0
7:50:04.565: → cacheMsg FileMsg [fileTime:1526784603.0, data:<data>, postFile:Routine.json]

rest on

7:50:24.643: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784603.0]]

dial

7:50:40.589: ⧉ saveData Routine.json 1526784603.0 ➛ 1526784640.0 𝚫37.0
7:50:40.619: ⧉ unarchiveSettings
7:50:40.628: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
7:50:40.631: ⧉ Settings::settingsFromRoot() saySet:7
7:50:40.654: ⧉ unarchiveData:Memos.json count:0
7:50:40.729: ⧉ unarchiveData:Marks.json count:0
7:50:40.781: ⧉ unarchiveData:Calendars.json count:0
7:50:41.619: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526784640.0]]
7:50:41.771: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526784640, getFile:Routine.json]
7:50:41.802: ⧉ sendPostFile fileName:Routine.json fileTime:1526784640.0
7:50:41.811: → cacheMsg FileMsg [fileTime:1526784640.0, data:<data>, postFile:Routine.json]

routine off - no affect on phone

------------------------------

8:00:37.432: ⧉ saveData Routine.json 1526785202.0 ➛ 1526785237.0 𝚫35.0
8:00:37.458: ⧉ unarchiveSettings
8:00:37.466: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
8:00:37.471: ⧉ Settings::settingsFromRoot() saySet:7
8:00:37.496: ⧉ unarchiveData:Memos.json count:0
8:00:37.586: ⧉ unarchiveData:Marks.json count:0
8:00:37.626: ⧉ unarchiveData:Calendars.json count:0
8:00:38.460: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526785237.0]]
8:00:38.653: ← session(_:didReceiveApplicationContext:) FileMsg [fileTime:1526785237, getFile:Routine.json]
8:00:38.687: ⧉ sendPostFile fileName:Routine.json fileTime:1526785237.0
8:00:38.699: → cacheMsg FileMsg [fileTime:1526785237.0, data:<data>, postFile:Routine.json]

8:01:15.496: ⧉ saveData Routine.json 1526785237.0 ➛ 1526785275.0 𝚫38.0
8:01:15.525: ⧉ unarchiveSettings
8:01:15.533: ⧉ unarchiveData:Settings.json memoryTime:1526784423.0 count:80 bytes
8:01:15.543: ⧉ Settings::settingsFromRoot() saySet:7
8:01:15.561: unarchiveData:Memos.json count:0
8:01:15.700: ⧉ unarchiveData:Marks.json count:0
8:01:15.705: ⧉ unarchiveData:Calendars.json count:0
8:01:16.525: → cacheMsg FileMsg [nameTimes:["Menu.json": 1526784272.0, "Settings.json": 1526784423.0, "Routine.json": 1526785275.0]]

