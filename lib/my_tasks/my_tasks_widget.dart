import '/auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/create_task_new_widget.dart';
import '/components/empty_list_tasks_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'my_tasks_model.dart';
export 'my_tasks_model.dart';

class MyTasksWidget extends StatefulWidget {
  const MyTasksWidget({Key? key}) : super(key: key);

  @override
  _MyTasksWidgetState createState() => _MyTasksWidgetState();
}

class _MyTasksWidgetState extends State<MyTasksWidget>
    with TickerProviderStateMixin {
  late MyTasksModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'containerOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(0.0, 70.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyTasksModel());

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'myTasks',
        color: FlutterFlowTheme.of(context).primaryColor,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Color(0x230E151B),
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.0,
                      child: CreateTaskNewWidget(),
                    ),
                  );
                },
              ).then((value) => setState(() {}));
            },
            backgroundColor: FlutterFlowTheme.of(context).primaryColor,
            elevation: 8.0,
            child: Icon(
              Icons.add_rounded,
              color: FlutterFlowTheme.of(context).white,
              size: 28.0,
            ),
          ),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryColor,
            automaticallyImplyLeading: false,
            title: Text(
              'My Tasks',
              style: FlutterFlowTheme.of(context).title1.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).white,
                  ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 0.0,
          ),
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: 53.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: Image.asset(
                            'assets/images/waves@2x.png',
                          ).image,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Scheduled Tasks',
                        style: FlutterFlowTheme.of(context).subtitle2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                    child: PagedListView<DocumentSnapshot<Object?>?,
                        ToDoListRecord>(
                      pagingController: () {
                        final Query<Object?> Function(Query<Object?>)
                            queryBuilder = (toDoListRecord) => toDoListRecord
                                .where('user', isEqualTo: currentUserReference)
                                .where('toDoState', isEqualTo: false)
                                .orderBy('toDoDate');
                        if (_model.pagingController != null) {
                          final query = queryBuilder(ToDoListRecord.collection);
                          if (query != _model.pagingQuery) {
                            // The query has changed
                            _model.pagingQuery = query;
                            _model.streamSubscriptions
                                .forEach((s) => s?.cancel());
                            _model.streamSubscriptions.clear();
                            _model.pagingController!.refresh();
                          }
                          return _model.pagingController!;
                        }

                        _model.pagingController =
                            PagingController(firstPageKey: null);
                        _model.pagingQuery =
                            queryBuilder(ToDoListRecord.collection);
                        _model.pagingController!
                            .addPageRequestListener((nextPageMarker) {
                          queryToDoListRecordPage(
                            queryBuilder: (toDoListRecord) => toDoListRecord
                                .where('user', isEqualTo: currentUserReference)
                                .where('toDoState', isEqualTo: false)
                                .orderBy('toDoDate'),
                            nextPageMarker: nextPageMarker,
                            pageSize: 25,
                            isStream: true,
                          ).then((page) {
                            _model.pagingController!.appendPage(
                              page.data,
                              page.nextPageMarker,
                            );
                            final streamSubscription =
                                page.dataStream?.listen((data) {
                              data.forEach((item) {
                                final itemIndexes = _model
                                    .pagingController!.itemList!
                                    .asMap()
                                    .map((k, v) => MapEntry(v.reference.id, k));
                                final index = itemIndexes[item.reference.id];
                                final items =
                                    _model.pagingController!.itemList!;
                                if (index != null) {
                                  items.replaceRange(index, index + 1, [item]);
                                  _model.pagingController!.itemList = {
                                    for (var item in items) item.reference: item
                                  }.values.toList();
                                }
                              });
                              setState(() {});
                            });
                            _model.streamSubscriptions.add(streamSubscription);
                          });
                        });
                        return _model.pagingController!;
                      }(),
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      builderDelegate:
                          PagedChildBuilderDelegate<ToDoListRecord>(
                        // Customize what your widget looks like when it's loading the first page.
                        firstPageProgressIndicatorBuilder: (_) => Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              color: FlutterFlowTheme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        noItemsFoundIndicatorBuilder: (_) => Center(
                          child: EmptyListTasksWidget(),
                        ),
                        itemBuilder: (context, _, listViewIndex) {
                          final listViewToDoListRecord =
                              _model.pagingController!.itemList![listViewIndex];
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 8.0),
                            child: InkWell(
                              onTap: () async {
                                context.pushNamed(
                                  'TaskDetails',
                                  queryParams: {
                                    'toDoNote': serializeParam(
                                      listViewToDoListRecord.reference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 5.0,
                                      color: Color(0x230E151B),
                                      offset: Offset(0.0, 2.0),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 12.0, 0.0, 12.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              listViewToDoListRecord.toDoName!,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .title2,
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 4.0, 0.0, 0.0),
                                                  child: Text(
                                                    dateTimeFormat(
                                                        'MMMEd',
                                                        listViewToDoListRecord
                                                            .toDoDate!),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .subtitle2,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          4.0, 4.0, 0.0, 0.0),
                                                  child: Text(
                                                    dateTimeFormat(
                                                        'jm',
                                                        listViewToDoListRecord
                                                            .toDoDate!),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .subtitle2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 12.0, 0.0),
                                          child: ToggleIcon(
                                            onPressed: () async {
                                              final toDoListUpdateData = {
                                                'toDoState':
                                                    !listViewToDoListRecord
                                                        .toDoState!,
                                              };
                                              await listViewToDoListRecord
                                                  .reference
                                                  .update(toDoListUpdateData);
                                            },
                                            value: listViewToDoListRecord
                                                .toDoState!,
                                            onIcon: Icon(
                                              Icons.check_circle,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryColor,
                                              size: 25.0,
                                            ),
                                            offIcon: Icon(
                                              Icons.radio_button_off,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 25.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ).animateOnPageLoad(
                                animationsMap['containerOnPageLoadAnimation']!),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
