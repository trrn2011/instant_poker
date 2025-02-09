import 'package:flutter/material.dart';
import 'package:instant_poker/widgets/circle_container_widget.dart';
import 'package:instant_poker/widgets/ringgame_field_widget.dart';
import '../utils/colors_util.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class TopScreen extends StatelessWidget {
  const TopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorsUtil.backgroundPurple,
        body: Column(
          children: [
            SafeArea(
              child: Container(
                padding: EdgeInsets.only(
                    left: 21.0, top: 21.0, right: 21.0, bottom: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CircleContainerWidget(
                        child: Text(
                          'Player Name',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        maxWidth: 220.0,
                      ),
                    ),
                    SizedBox(width: 24.0), // スペースを追加
                    CircleContainerWidget(
                      child: Text(
                        'Play Time',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      maxWidth: 105.0,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/poker_table.png'),
                    fit: BoxFit.contain,
                  ),
                  border:
                      Border.all(color: Colors.white, width: 2.0), // ボーダーラインを追加
                ),
                padding: EdgeInsets.symmetric(horizontal: 76.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NLH',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16.0),
                    Column(children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Tab 1'),
                          Tab(text: 'Tab 2'),
                        ],
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.white,
                      ),
                      Container(
                        height: 500,
                        child: TabBarView(
                          children: [
                            RingGameFieldWidget(),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Content for Tab 2'),
                                  SizedBox(height: 16.0),
                                  TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Enter Text',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.only(
                    left: 16.0, top: 0.0, right: 16.0, bottom: 16.0),
                color: const Color.fromARGB(255, 128, 0, 255),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleContainerWidget(
                      child: Icon(Icons.volume_up, color: Colors.white),
                      maxWidth: 35.0,
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(width: 16.0), // スペースを追加
                    CircleContainerWidget(
                      child: Text(
                        'ゲーム履歴',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      maxWidth: 295.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
