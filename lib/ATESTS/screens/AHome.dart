import 'dart:async';
import 'dart:developer';

import 'package:aft/ATESTS/screens/poll_card.dart';
import 'package:aft/ATESTS/screens/report_user_screen.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/APost.dart';
import '../models/AUser.dart';
import '../models/poll.dart';
import '../other/AUtils.dart';
import '../provider/AUserProvider.dart';
import 'ACountries.dart';
import 'ACountriesValues.dart';
import 'add_screen.dart';
import 'post_card.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({
    Key? key,
  }) : super(key: key);
  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  var messages = 'true';
  var global = 'true';

  //String oneValue = '';
  // String twoValue = '';
  //String threeValue = '';
  int selectedCountryIndex = -1;

  //String flag = 'us';
  List<Post> postsList = [];
  StreamSubscription? loadDataStream;
  StreamController<Post> updatingStream = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    loadCountryFilterValue();
    getValueG().then(((value) => getValueM().then((value) =>
        initList()))); // this has to be like this, to wait for the get functions to be executed first
    //new changes
    //we are changed ACountries file,
    //-----old changes
    //we are initialy filling postList when page is loaded.
    //every elements is subscribed on loadDataStream and listening on the event that is meant to it. (look at the changes in the Post class)
  }

  @override
  void dispose() {
    super.dispose();
    if (loadDataStream != null) {
      loadDataStream!.cancel();
    }
  }

  Future<void> initList() async {
    if (loadDataStream != null) {
      loadDataStream!.cancel();
      postsList = [];
    }
    loadDataStream = (global == "true"
            ? FirebaseFirestore.instance.collection('posts')
            : FirebaseFirestore.instance
                .collection('posts')
                .where("country", isEqualTo: short[selectedCountryIndex]))
        .where("global", isEqualTo: global)
        .orderBy("score", descending: true)
        .orderBy("datePublished", descending: false)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            postsList.add(Post.fromMap({
              ...change.doc.data()!,
              'updatingStream': updatingStream
            })); // we are adding to a local list when the element is added in firebase collection
            break; //the Post element we will send on pair with updatingStream, because a Post constructor makes a listener on a stream.
          case DocumentChangeType.modified:
            updatingStream.add(Post.fromMap({
              ...change.doc.data()!
            })); // we are sending a modified object in the stream.
            break;
          case DocumentChangeType.removed:
            postsList.remove(Post.fromMap({
              ...change.doc.data()!
            })); // we are removing a Post object from the local list.
            break;
        }
      }
      setState(() {});
    });
  }

  Future<void> getValueG() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio3') != null) {
      setState(() {
        global = prefs.getString('selected_radio3')!;
      });
    }
  }

  Future<void> setValueG(String valueg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      global = valueg.toString();
      prefs.setString('selected_radio3', global);
      initList();
    });
  }

  Future<void> getValueM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio4') != null) {
      setState(() {
        messages = prefs.getString('selected_radio4')!;
      });
    }
  }

  Future<void> setValueM(String valuem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      messages = valuem.toString();
      if (valuem == "true") {
        initList();
      }
      prefs.setString('selected_radio4', messages);
    });
  }

  _otherUsers(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.block),
                    Container(width: 10),
                    const Text('Block User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {},
                  );
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.report),
                    Container(width: 10),
                    const Text('Report User',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  performLoggedUserAction(
                    context: context,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ReportUserScreen()),
                      );
                    },
                  );
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    Container(width: 10),
                    const Text('Close',
                        style: TextStyle(letterSpacing: 0.2, fontSize: 15)),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 236, 234, 234),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              // elevation: 5,
              // forceElevated: true,
              toolbarHeight: 92,
              // backgroundColor: Color.fromARGB(255, 241, 239, 239),
              backgroundColor: Colors.white,
              actions: [
                SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -6,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Countries())).then(
                                  (value) =>
                                      {loadCountryFilterValue(), initList()});
                            },
                            icon: const Icon(Icons.filter_list,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        left: 315,
                        child:
                            // Padding(
                            //   padding: const EdgeInsets.only(left: 315.0),
                            //   child:
                            IconButton(
                          onPressed: () => _otherUsers(context),
                          icon: const Icon(Icons.settings, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 35.0, left: 239, right: 9),
                        child: Column(
                          children: [
                            Text(
                              messages == 'true' ? 'Messages' : 'Polls',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            AnimatedToggleSwitch<String>.rollingByHeight(
                                height: 34,
                                current: messages,
                                values: const [
                                  'true',
                                  'false',
                                ],
                                onChanged: (valuem) =>
                                    setValueM(valuem.toString()),
                                iconBuilder: rollingIconBuilderStringTwo,
                                borderRadius: BorderRadius.circular(75.0),
                                indicatorSize: const Size.square(1.8),
                                innerColor: Color.fromARGB(255, 203, 203, 203),
                                indicatorColor: Colors.black,
                                borderColor:
                                    // Color.fromARGB(255, 234, 232, 232),
                                    Colors.white,
                                iconOpacity: 1),
                          ],
                        ),
                      ),
                      global == 'true'
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 35.0, left: 10),
                              child: Column(
                                children: [
                                  Text(
                                    'Global',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  AnimatedToggleSwitch<String>.rollingByHeight(
                                      height: 34,
                                      current: global,
                                      values: const [
                                        'true',
                                        'false',
                                      ],
                                      onChanged: (valueg) =>
                                          setValueG(valueg.toString()),
                                      iconBuilder:
                                          rollingIconBuilderStringThree,
                                      borderRadius: BorderRadius.circular(75.0),
                                      indicatorSize: const Size.square(1.8),
                                      innerColor:
                                          Color.fromARGB(255, 203, 203, 203),
                                      indicatorColor: Colors.black,
                                      borderColor: Colors.white,
                                      iconOpacity: 1),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 35.0, left: 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'National',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      selectedCountryIndex == -1
                                          ? Container()
                                          : Container(
                                              width: 24,
                                              height: 14,
                                              child: Image.asset(
                                                  'icons/flags/png/${short[selectedCountryIndex]}.png',
                                                  package: 'country_icons'),
                                            ),
                                    ],
                                  ),
                                  AnimatedToggleSwitch<String>.rollingByHeight(
                                      height: 34,
                                      current: global,
                                      values: const [
                                        'true',
                                        'false',
                                      ],
                                      onChanged: (valueg) =>
                                          setValueG(valueg.toString()),
                                      iconBuilder:
                                          rollingIconBuilderStringThree,
                                      borderRadius: BorderRadius.circular(75.0),
                                      indicatorSize: const Size.square(1.8),
                                      innerColor:
                                          Color.fromARGB(255, 203, 203, 203),
                                      indicatorColor: Colors.black,
                                      borderColor: Colors.white,
                                      iconOpacity: 1),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 154),
                        child: IconButton(
                          onPressed: () {
                            performLoggedUserAction(
                                context: context,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddPost()),
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.create,
                            color: Colors.black,
                            size: 38,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 60, left: 162),
                        child: IconButton(
                          onPressed: () {
                            performLoggedUserAction(
                                context: context,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddPost()),
                                  );
                                });
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          body: //global == "true" && messages == "true"
              // ?
              //global variable doesn't look into here, because we are using unique list(postsList) for filling up model
              //look at the function initList(), it is called when global variable is changed
              messages == "true"
                  ? ListView.builder(
                      itemCount: postsList.length,
                      itemBuilder: (context, index) {
                        print('GETTING LIST');
                        print(
                            'snapshot.data!.docs[index].data(): ${postsList[index]}');
                        // Post post = Post.fromSnap(snapshot.data!.docs[index]);
                        final User? user =
                            Provider.of<UserProvider>(context).getUser;
                        print(
                            '_post.plus.contains(user.uid): ${postsList[index].plus.contains(user?.uid)}');
                        return PostCard(
                          post: postsList[index],
                          indexPlacement: index,
                        );
                      })
                  /* : global == "false" && messages == "true"
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where("global", isEqualTo: global)
                          .where("country", isEqualTo: flag)
                          .orderBy("score", descending: true)
                          .orderBy("datePublished", descending: false)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              // print('GETTTING LIST');
                              // print(
                              //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
                              Post post =
                                  Post.fromSnap(snapshot.data!.docs[index]);
                              final User? user =
                                  Provider.of<UserProvider>(context).getUser;
                              // print(
                              //     '_post.plus.contains(user.uid): ${post.plus.contains(user?.uid)}');
                              return PostCard(
                                post: post,
                                indexPlacement: index,
                              );
                            });
                        //   itemCount: snapshot.data!.docs.length,
                        //   itemBuilder: (context, index) {
                        //     return PostCardTest(
                        //       snap: snapshot.data!.docs[index].data(),
                        //       indexPlacement: index,
                        //     );
                        //   },
                        // );
                      },
                    )*/

                  //DISPLAY POLLS LIST
                  : global == "true" && messages == "false"
                      ? StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('polls')
                              .where("global", isEqualTo: global)
                              .orderBy("totalVotes", descending: true)
                              .orderBy("datePublished", descending: false)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  // print('GETTTING LIST');
                                  // print(
                                  //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
                                  Poll poll =
                                      Poll.fromSnap(snapshot.data!.docs[index]);
                                  final User? user =
                                      Provider.of<UserProvider>(context)
                                          .getUser;
                                  // print(
                                  //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
                                  return PollCard(
                                    poll: poll,
                                    // indexPlacement: index,
                                  );
                                });
                            //   itemBuilder: (context, index) {
                            //     return PostCardTest(
                            //       snap: snapshot.data!.docs[index].data(),

                            //       indexPlacement: index,
                            //     );
                            //   },
                            // );
                          },
                        )
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('polls')
                              .where("global", isEqualTo: global)
                              .where("country",
                                  isEqualTo: short[selectedCountryIndex])
                              .orderBy("totalVotes", descending: true)
                              .orderBy("datePublished", descending: false)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  // print('GETTTING LIST');
                                  // print(
                                  //     'snapshot.data!.docs[index].data(): ${snapshot.data!.docs[index].data()}');
                                  Poll poll =
                                      Poll.fromSnap(snapshot.data!.docs[index]);
                                  final User? user =
                                      Provider.of<UserProvider>(context)
                                          .getUser;
                                  // print(
                                  //     '_post.plus.contains(user.uid): ${poll.plus.contains(user?.uid)}');
                                  return PollCard(
                                    poll: poll,
                                    // indexPlacement: index,
                                  );
                                });
                          },
                        ),
        ),
      ),
    );
  }

  Widget rollingIconBuilderStringTwo(
      String messages, Size iconSize, bool foreground) {
    IconData data = Icons.poll;
    if (messages == 'true') data = Icons.message;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  Widget rollingIconBuilderStringThree(
      String global, Size iconSize, bool foreground) {
    IconData data = Icons.flag;
    if (global == 'true') data = Icons.public;
    return Icon(data, size: iconSize.shortestSide, color: Colors.white);
  }

  loadCountryFilterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountryIndex = prefs.getInt('countryRadio') ?? -1;
      // prefs.getInt('selected_radio') ?? '';
      //oneValue = prefs.getString('selected_radio') ?? '';
      //twoValue = prefs.getString('selected_radio1') ?? '';
      //threeValue = prefs.getString('selected_radio2') ?? '';
    });
  }
}
