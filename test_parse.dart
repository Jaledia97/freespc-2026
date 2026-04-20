import 'dart:convert';
import 'package:freespc/models/venue_model.dart';
import 'package:freespc/models/venue_program_model.dart';

void main() {
  const jsonStr = '''{
    "zipCode": "32569",
    "city": "Mary Esther",
    "geoHash": "dj6kgzqtt",
    "isActive": true,
    "name": "Mary Esther Bingo",
    "id": "mary-esther-bingo",
    "followBonus": 50,
    "beaconUuid": "mock-mary-esther-bingo",
    "geo": {
      "geohash": "dj6mh1vb5",
      "geopoint": {
        "_latitude": 30.4197912,
        "_longitude": -86.6520956
      }
    },
    "phone": "+18502264359",
    "websiteUrl": "Maryestherbingo.com",
    "street": "481 Mary Esther Blvd",
    "latitude": 30.4197912,
    "bannerUrl": "https://firebasestorage.googleapis.com/v0/b/freespc-2026.firebasestorage.app/o/halls%2Fmary-esther-bingo%2Fbanner_v1770358452739.jpg?alt=media&token=2a41ea6c-2171-4c68-b09d-6d2715c1ce42",
    "state": "Florida",
    "logoUrl": "https://firebasestorage.googleapis.com/v0/b/freespc-2026.firebasestorage.app/o/halls%2Fmary-esther-bingo%2Flogo_v1770358462349.jpg?alt=media&token=86eaf20c-7c50-4914-a252-74548dcd4a0d",
    "longitude": -86.6520956,
    "description": "Welcome",
    "unitNumber": "",
    "programs": []
  }''';

  try {
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    final model = VenueModel.fromJson(data);
    print("SUCCESS: Parsing worked => \${model.name}");
  } catch (e, stack) {
    print("PARSING ERROR: \$e");
    print(stack);
  }
}
