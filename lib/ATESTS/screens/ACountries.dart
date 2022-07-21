import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ACountriesValues.dart';

class Countries extends StatefulWidget {
  @override
  State<Countries> createState() => _CountriesState();
}

class _CountriesState extends State<Countries> {
  final TextEditingController _countriesController = TextEditingController();

  String searchText = '';

  int selectedCountryIndex = short.indexOf('us');

  @override
  void initState() {
    super.initState();
    getValue();
    _countriesController.addListener(_filterList);
  }

  @override
  void dispose() {
    _countriesController.dispose();
    super.dispose();
  }

  void _filterList() {
    // this is calle on evey keystroke.
    print('Search value: ${_countriesController.text}');

    setState(() {
      searchText = _countriesController.text.toLowerCase();
    });
  }

  Future<void> getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selected_radio') != null) {
      setState(() {
        selectedCountryIndex = prefs.getInt('countryRadio')!;
      });
    }
  }

  Future<void> setValue(int countryIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountryIndex = countryIndex;
      prefs.setInt('countryRadio', selectedCountryIndex);
      prefs.setString('selected_radio', long[selectedCountryIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> filtedlist = long
        .where(
            (c) => c.toLowerCase().startsWith(searchText) || searchText == '')
        .toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 240, 239, 239),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 240, 239, 239),
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 95,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextField(
                    controller: _countriesController,
                    decoration: const InputDecoration(
                      hintText: "Search Countries",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    maxLines: null,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  itemCount: filtedlist.length,
                  controller: ScrollController(),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => MyRadioListTile(
                      selectedIndex: selectedCountryIndex,
                      index: long.indexOf(filtedlist[index]),
                      onChanged: (value) => setValue(value)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyRadioListTile extends StatelessWidget {
  final int selectedIndex;
  final int index;
  final ValueChanged<int> onChanged;

  const MyRadioListTile({
    required this.onChanged,
    required this.selectedIndex,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(index),
      child: Container(
        height: 41,
        child: Container(
          child: _customRadioButton,
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    String flag = short[index];
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: index == selectedIndex
            ? Color.fromARGB(255, 111, 111, 111)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Container(
              width: 25,
              height: 15,
              child: Image.asset('icons/flags/png/${flag}.png',
                  package: 'country_icons'),
            ),
          ),
          Center(
            child: Container(
              width: 74,
              child: Text(
                long[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      index == selectedIndex ? Colors.white : Colors.grey[600]!,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
