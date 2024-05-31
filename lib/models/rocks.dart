import 'package:flutter_onboarding/db/db.dart';

class Rock {

  final int rockId;
  final double price;
  final String size;
  final int rating;
  final double humidity;
  final String temperature;
  final String category;
  final String rockName;
  final String imageURL;
  bool isFavorited;
  final String description;
  bool isSelected;

  Rock(
      {required this.rockId,
        required this.price,
        required this.category,
        required this.rockName,
        required this.size,
        required this.rating,
        required this.humidity,
        required this.temperature,
        required this.imageURL,
        required this.isFavorited,
        required this.description,
        required this.isSelected});

        Map<String, dynamic> toMap() {
    return {
      'price': price,
      'category': category,
      'rockName': rockName,
      'size': size,
      'rating': rating,
      'humidity': humidity,
      'temperature': temperature,
      'imageURL': imageURL,
      'isFavorited': isFavorited ? 1 : 0,
      'description': description,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  // Implement a fromMap method to convert a Map into a Rock object.
  factory Rock.fromMap(Map<String, dynamic> map) {
    return Rock(
      rockId: map['rockId'] ?? 0,
      price:  map['price'] ?? 0,
      category: map['category'] ?? '',
      rockName: map['rockName'] ?? '',
      size: map['size'] ?? '',
      rating: map['rating'] ?? 0,
      humidity: map['humidity'] ?? 0,
      temperature: map['temperature'] ?? '',
      imageURL: map['imageURL'] ?? '',
      isFavorited: ( map['isFavorited'] ?? 0) == 1,
      description: map['description'] ?? '',
      isSelected: (map['isSelected'] ?? 0) == 1,
    );
  }
  
  static Future<List<Rock>> getFavoritedRocks() async{
    try{
      List<Rock> _travelList = await DatabaseHelper().rocks();
      return _travelList.where((element) => element.isFavorited == true).toList();
    }catch(e){
      print(e);
      return [];
    }
    
  }

  //Get the cart items
  static Future<List<Rock>> addedToCartRocks() async{
     try{
      List<Rock> _selectedRocks = await DatabaseHelper().rocks();
      return _selectedRocks.where((element) => element.isSelected == true).toList();
    }catch(e){
      print(e);
      return [];
    }
    
  }

/*

  //List of Rocks data
  static List<Rock> RockList = [
    Rock(
        RockId: 0,
        price: 22,
        category: 'Indoor',
        RockName: 'Sanseviera',
        size: 'Small',
        rating: 4.5,
        humidity: 34,
        temperature: '23 - 34',
        imageURL: 'assets/images/rock1.png',
        isFavorated: true,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 1,
        price: 11,
        category: 'Outdoor',
        RockName: 'Philodendron',
        size: 'Medium',
        rating: 4.8,
        humidity: 56,
        temperature: '19 - 22',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 2,
        price: 18,
        category: 'Indoor',
        RockName: 'Beach Daisy',
        size: 'Large',
        rating: 4.7,
        humidity: 34,
        temperature: '22 - 25',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 3,
        price: 30,
        category: 'Outdoor',
        RockName: 'Big Bluestem',
        size: 'Small',
        rating: 4.5,
        humidity: 35,
        temperature: '23 - 28',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 4,
        price: 24,
        category: 'Recommended',
        RockName: 'Big Bluestem',
        size: 'Large',
        rating: 4.1,
        humidity: 66,
        temperature: '12 - 16',
        imageURL: 'assets/images/rock1.png',
        isFavorated: true,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 5,
        price: 24,
        category: 'Outdoor',
        RockName: 'Meadow Sage',
        size: 'Medium',
        rating: 4.4,
        humidity: 36,
        temperature: '15 - 18',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 6,
        price: 19,
        category: 'Garden',
        RockName: 'Plumbago',
        size: 'Small',
        rating: 4.2,
        humidity: 46,
        temperature: '23 - 26',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 7,
        price: 23,
        category: 'Garden',
        RockName: 'Tritonia',
        size: 'Medium',
        rating: 4.5,
        humidity: 34,
        temperature: '21 - 24',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
    Rock(
        RockId: 8,
        price: 46,
        category: 'Recommended',
        RockName: 'Tritonia',
        size: 'Medium',
        rating: 4.7,
        humidity: 46,
        temperature: '21 - 25',
        imageURL: 'assets/images/rock1.png',
        isFavorated: false,
        decription:
        'This Rock is one of the best Rock. It grows in most of the regions in the world and can survive'
            'even the harshest weather condition.',
        isSelected: false),
  ];
   

  //Get the favorated items
  static List<Rock> getFavoritedRocks(){
    List<Rock> _travelList = Rock.RockList;
    return _travelList.where((element) => element.isFavorated == true).toList();
  }

  //Get the cart items
  static List<Rock> addedToCartRocks(){
    List<Rock> _selectedRocks = Rock.RockList;
    return _selectedRocks.where((element) => element.isSelected == true).toList();
  }
*/
 
}
