import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../configuration/configuration.dart';

class PetStoreScreen extends StatefulWidget {
  const PetStoreScreen({Key? key}) : super(key: key);

  @override
  State<PetStoreScreen> createState() => _PetStoreScreenState();
}

class _PetStoreScreenState extends State<PetStoreScreen> {
  final ScrollController _controller = ScrollController();

  ScrollPhysics _physics = const BouncingScrollPhysics();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      if (_controller.offset >= 20) {
        setState(() {
          _physics = const ClampingScrollPhysics();
        });
      } else {
        setState(() {
          _physics = const BouncingScrollPhysics();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _controller,
          physics: _physics,
          child: Column(
            children: [
              const SizedBox(
                height: 5.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => ZoomDrawer.of(context)!.toggle(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            const Text(
                              'Kyiv, ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Ukraine'),
                          ],
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      child: const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/pet_cat1.png'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                        ),
                        hintText: 'Search pet',
                        hintStyle: TextStyle(
                            letterSpacing: 1, color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon:
                            Icon(Icons.tune_sharp, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: shadowList,
                                  ),
                                  child: Image(
                                    image: AssetImage(
                                        categories[index]['imagePath']),
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  categories[index]['name'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // ListView.builder(
                  //   physics: ScrollPhysics(),
                  //   itemCount: catMapList.length,
                  //   scrollDirection: Axis.vertical,
                  //   shrinkWrap: true,
                  //   itemBuilder: (context, index) {
                  //     return Container(
                  //       height: 230,
                  //       margin: EdgeInsets.symmetric(horizontal: 20),
                  //       child: Row(
                  //         children: [
                  //           Expanded(
                  //             child: Stack(
                  //               children: [
                  //                 Container(
                  //                   decoration: BoxDecoration(
                  //                     color: (index % 2 == 0)
                  //                         ? Colors.blueGrey[200]
                  //                         : Colors.orangeAccent[200],
                  //                     borderRadius: BorderRadius.circular(20),
                  //                     boxShadow: shadowList,
                  //                   ),
                  //                   margin: EdgeInsets.only(top: 40),
                  //                 ),
                  //                 Align(
                  //                     child: Padding(
                  //                   padding: const EdgeInsets.all(8.0),
                  //                   child: Hero(
                  //                       tag: 'pet${catMapList[index]['id']}',
                  //                       child: Image.asset(
                  //                           catMapList[index]['imagePath'])),
                  //                 )),
                  //               ],
                  //             ),
                  //           ),
                  //           Expanded(
                  //             child: Container(
                  //               margin: EdgeInsets.only(top: 65, bottom: 20),
                  //               padding: EdgeInsets.all(15),
                  //               decoration: BoxDecoration(
                  //                 color: Colors.white,
                  //                 borderRadius: BorderRadius.only(
                  //                     topRight: Radius.circular(20),
                  //                     bottomRight: Radius.circular(20)),
                  //                 boxShadow: shadowList,
                  //               ),
                  //               child: Column(
                  //                 mainAxisAlignment:
                  //                     MainAxisAlignment.spaceAround,
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Text(
                  //                         catMapList[index]['name'],
                  //                         style: TextStyle(
                  //                           fontWeight: FontWeight.bold,
                  //                           fontSize: 21.0,
                  //                           color: Colors.grey[600],
                  //                         ),
                  //                       ),
                  //                       (catMapList[index]['sex'] == 'male')
                  //                           ? Icon(
                  //                               Icons.male_rounded,
                  //                               color: Colors.grey[500],
                  //                             )
                  //                           : Icon(
                  //                               Icons.female_rounded,
                  //                               color: Colors.grey[500],
                  //                             ),
                  //                     ],
                  //                   ),
                  //                   Text(
                  //                     catMapList[index]['Species'],
                  //                     style: TextStyle(
                  //                       fontWeight: FontWeight.bold,
                  //                       color: Colors.grey[500],
                  //                     ),
                  //                   ),
                  //                   Text(
                  //                     catMapList[index]['year'] + ' years old',
                  //                     style: TextStyle(
                  //                       fontSize: 12,
                  //                       color: Colors.grey[400],
                  //                     ),
                  //                   ),
                  //                   Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.start,
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.center,
                  //                     children: [
                  //                       Icon(
                  //                         Icons.location_on,
                  //                         color: Theme.of(context).primaryColor,
                  //                         size: 18,
                  //                       ),
                  //                       // SizedBox(
                  //                       //   width: 3,
                  //                       // ),
                  //                       Text(
                  //                         'Distance: ' +
                  //                             catMapList[index]['distance'],
                  //                         style: TextStyle(
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Colors.grey[400],
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
