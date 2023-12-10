part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> provinceData = [];

  bool isDataLoading = false;
  bool isDataLoadingCityOrigin = false;
  bool isDataLoadingCityDestination = false;

  dynamic provinceOriginId;
  dynamic selectedprovinceOrigin;
  dynamic provinceIdDestination;
  dynamic selectedprovinceDestination;
  dynamic cityDataOrigin;
  dynamic cityIdOrigin;
  dynamic selectedCityOrigin;
  dynamic cityDataDestination;
  dynamic cityIdDestination;
  dynamic selectedCityDestination;

 Future<dynamic> getProvinces() async {
    await MasterDataService.getProvince().then((value) {
      setState(() {
        provinceData = value;
      });
    });
  }

  Future<List<City>> getCities(var provinceId, var originORdestination) async {
    dynamic city;
    await MasterDataService.getCity(provinceId).then((value) {
      setState(() {
        city = value;
        if (originORdestination == 'origin') {
          isDataLoadingCityOrigin = false;
        } else {
          isDataLoadingCityDestination = false;
        }
      });
    });

    return city;
  }

  var selectedCourier = 'jne';
  List<Costs> costData = [];

  Future<dynamic> getCost(
      var courier, var origin, var destination, var weight) async {

    dynamic costs;
    await MasterDataService.getCost(origin, destination, weight, courier)
        .then((value) {
      setState(() {
        costs = value;
      });
      isDataLoading = false;
    });

    return costs;
  }

  var weight = 0;

  @override
  void initState() {
    super.initState();
    getProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Hitung Ongkir"),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: isDataLoading,
        child: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: DropdownButtonFormField(
                                  items: [
                                    DropdownMenuItem(
                                      value: 'jne',
                                      child: Text('jne'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'pos',
                                      child: Text('pos'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'tiki',
                                      child: Text('tiki'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCourier = value as String;
                                    });
                                  },
                                  value: selectedCourier,
                                  isDense: true,
                                  isExpanded: false,
                                ),
                              ),
                              SizedBox(width: 30),
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Berat (gr)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      weight = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Origin",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButton(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceOriginId = value;
                                            isDataLoadingCityOrigin = true;
                                            selectedCityOrigin = null;
                                            cityDataOrigin = getCities(
                                                provinceOriginId, 'origin');
                                          });
                                          cityIdOrigin = null;
                                        },
                                        value: provinceOriginId,
                                        isExpanded: true,
                                        hint: selectedCityOrigin == null
                                            ? Text('Select Province')
                                            : Text(selectedCityOrigin.province),
                                      ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataOrigin,
                                  builder: (context, snapshot) {
                                    if (isDataLoadingCityOrigin) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityOrigin,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: selectedCityOrigin == null
                                            ? Text('Pilih kota')
                                            : Text(selectedCityOrigin.cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityOrigin = newValue;
                                            cityIdOrigin =
                                                selectedCityOrigin.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Tidak ada data");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: Text('Pilih kota'),
                                        items: [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Destination",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButton(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceIdDestination = value;
                                            isDataLoadingCityDestination = true;
                                            selectedCityDestination = null;
                                            cityDataDestination = getCities(
                                                provinceIdDestination,
                                                'destination');
                                            cityIdDestination = null;
                                          });
                                        },
                                        value: provinceIdDestination,
                                        isExpanded: true,
                                        hint: selectedprovinceDestination ==
                                                null
                                            ? Text('Select Province')
                                            : Text(selectedprovinceDestination
                                                .province),
                                      ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataDestination,
                                  builder: (context, snapshot) {
                                    if (isDataLoadingCityDestination) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: selectedCityDestination == null
                                            ? Text('Pilih kota')
                                            : Text(selectedCityDestination
                                                .cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityDestination = newValue;
                                            cityIdDestination =
                                                selectedCityDestination.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Tidak ada data");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: TextStyle(color: Colors.black),
                                        hint: Text('Pilih kota'),
                                        items: [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 16.0), // Add top padding
                              child: ElevatedButton(
                                onPressed: () {
                                  if (cityIdDestination == null ||
                                      cityIdOrigin == null ||
                                      weight < 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please insert all the needed data!'),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isDataLoading = true;
                                    });
                                    setState(() async {
                                      costData = await getCost(
                                        selectedCourier,
                                        cityIdOrigin,
                                        cityIdDestination,
                                        weight,
                                      );
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20.0), // Adjust the value for roundness
                                  ),
                                  primary: Colors
                                      .green, // Set the button color to green
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      12.0), // Adjust the value for smaller padding
                                  child: Text(
                                    'Hitung Estimasi harga',
                                    style: TextStyle(
                                      color: Colors
                                          .white, 
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: costData.isEmpty || costData[0].cost.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: Text("Tidak Ada Data"),
                            )
                          : ListView.builder(
                              itemCount: costData.length,
                              itemBuilder: (context, index) {
                                return CardProvince(costData[index]);
                              })),
                ),
              ],
            ),
            isDataLoading == true ? UiLoading.loadingBlock() : Container()
          ],
        ),
      ),
    );
  }
}
