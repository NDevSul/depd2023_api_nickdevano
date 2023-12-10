part of 'services.dart';

class MasterDataService {
  static Future<List<Province>> getProvince() async {
    var response = await http.get(Uri.https(Const.baseUrl, "/starter/province"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        });

    var job = json.decode(response.body);
    List<Province> result = [];

    if (response.statusCode == 200) {
      result = (job['rajaongkir']['results'] as List)
          .map((e) => Province.fromJson(e))
          .toList();
    }
    return result;
  }

  static Future<List<City>> getCity(var provId) async {
    var response = await http.get(Uri.https(Const.baseUrl, "/starter/city"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        });

    var job = json.decode(response.body);
    List<City> result = [];
    if (response.statusCode == 200) {
      result = (job['rajaongkir']['results'] as List)
          .map((e) => City.fromJson(e))
          .toList();
    }

    List<City> selectedCities = [];
    for (var c in result) {
      if (c.provinceId == provId) {
        selectedCities.add(c);
      }
    }

    return selectedCities;
  }

  static Future<List<Costs>> getCost(
      var origin, var dest, var weight, var courier) async {
    Map<String, dynamic> requestBody = {
      "origin": origin,
      "destination": dest,
      "weight": weight,
      "courier": courier,
    };

    String requestBodyJson = jsonEncode(requestBody);
    var response = await http.post(
      Uri.https(Const.baseUrl, "/starter/cost"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'key': Const.apiKey,
      },
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var costsList = data['rajaongkir']['results'][0]['costs'] as List?;

      if (costsList != []) {
        List<Costs> costData = costsList!
            .map((e) => Costs.fromJson(e as Map<String, dynamic>))
            .toList();

        return costData;
      }
    }

    return [];
  }
}
