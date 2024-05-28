class Rock {
  final int RockId;
  final int price;
  final String size;
  final double rating;
  final int humidity;
  final String temperature;
  final String category;
  final String RockName;
  final String imageURL;
  bool isFavorated;
  final String decription;
  bool isSelected;

  Rock(
      {required this.RockId,
        required this.price,
        required this.category,
        required this.RockName,
        required this.size,
        required this.rating,
        required this.humidity,
        required this.temperature,
        required this.imageURL,
        required this.isFavorated,
        required this.decription,
        required this.isSelected});

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
}
