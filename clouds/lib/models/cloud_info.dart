class CloudInfo {
  final int id;
  final String name;
  final String description;
  final String formation;
  final String atmosphericLayer;
  final String cause;
  final String weatherImpact;
  final String imageUrl;

  CloudInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.formation,
    required this.atmosphericLayer,
    required this.cause,
    required this.weatherImpact,
    required this.imageUrl,
  });

  // ฟังก์ชันจาก map
  factory CloudInfo.fromMap(Map<String, dynamic> map) {
    return CloudInfo(
      id: map['id'] ?? 0, // ถ้าค่า id เป็น null ให้ใช้ 0
      name: map['name'] ?? 'ไม่มีชื่อเมฆ', // ถ้าค่า name เป็น null ให้ใช้ค่าเริ่มต้น
      description: map['description'] ?? 'ไม่มีข้อมูลรายละเอียดเมฆ', // ถ้าค่า description เป็น null ให้ใช้ค่าเริ่มต้น
      formation: map['formation'] ?? 'ข้อมูลไม่ครบถ้วน', // ค่าเริ่มต้น
      atmosphericLayer: map['atmospheric_layer'] ?? 'ข้อมูลไม่ครบถ้วน', // ค่าเริ่มต้น
      cause: map['cause'] ?? 'ข้อมูลไม่ครบถ้วน', // ค่าเริ่มต้น
      weatherImpact: map['weather_impact'] ?? 'ข้อมูลไม่ครบถ้วน', // ค่าเริ่มต้น
      imageUrl: map['image_url'] ?? '', // ถ้า image_url เป็น null ให้ใช้ค่าเริ่มต้น
    );
  }

  // ฟังก์ชันแปลงเป็น map เพื่อเก็บในฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'formation': formation,
      'atmospheric_layer': atmosphericLayer,
      'cause': cause,
      'weather_impact': weatherImpact,
      'image_url': imageUrl,
    };
  }
}
