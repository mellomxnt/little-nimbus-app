import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cloud_info.dart';

class CloudDatabase {
  static final CloudDatabase instance = CloudDatabase._init();
  static Database? _database;

  CloudDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('clouds.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clouds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        formation TEXT,
        atmospheric_layer TEXT,
        cause TEXT,
        weather_impact TEXT,
        image_url TEXT
      )
    ''');

    await _insertInitialData(db);
  }

  Future _insertInitialData(Database db) async {
    final clouds = [
      {
        'name': 'cumulus',
        'description': 'เมฆคิวมูลัสมีลักษณะกลมฟูและเป็นสีขาวสว่างเมื่อได้รับแสงแดด ส่วนล่างแบนและค่อนข้างมืด',
        'formation': 'เกิดในวันที่อากาศแจ่มใสและมีแดดจัดเมื่อแสงอาทิตย์ทำให้พื้นดินร้อนขึ้นโดยการพาความร้อน',
        'atmospheric_layer': 'ชั้นบรรยากาศต่ำ (ต่ำกว่า 2,000 เมตร)',
        'cause': 'เกิดจากการระเหยและการลอยขึ้นของอากาศร้อนที่มีความชื้นสูงในชั้นบรรยากาศ',
        'weather_impact': 'มักบ่งบอกถึงสภาพอากาศที่ดีและแดดจัดในช่วงเช้าและบ่าย',
        'image_url': 'assets/cumulus.jpg',
      },
      {
        'name': 'stratus',
        'description': 'เมฆสเตรตัสลอยต่ำบนท้องฟ้าเป็นชั้นเมฆสีเทาเรียบๆ มีลักษณะคล้ายหมอกที่ปกคลุมขอบฟ้า',
        'formation': 'มักเกิดในวันที่ท้องฟ้ามืดครึ้มและมีหมอกหรือละอองฝนเล็กน้อย',
        'atmospheric_layer': 'ชั้นบรรยากาศต่ำ',
        'cause': 'เกิดจากความชื้นสะสมในอากาศที่มีการเย็นลง ทำให้เกิดการควบแน่นและกลั่นตัว',
        'weather_impact': 'มักทำให้ท้องฟ้ามืดครึ้มและอาจนำมาซึ่งฝนเบาหรือหมอก',
        'image_url': 'assets/stratus.jpg',
      },
      {
        'name': 'stratocumulus',
        'description': 'เมฆสเตรโตคิวมูลัสเป็นเมฆสีเทาหรือสีขาวที่ลอยต่ำ มีลักษณะเป็นก้อนเมฆป่องๆ',
        'formation': 'เกิดจากการพาความร้อนอ่อนๆ ในชั้นบรรยากาศ โดยส่วนใหญ่พบในวันที่อากาศครึ้ม',
        'atmospheric_layer': 'ชั้นบรรยากาศต่ำถึงกลาง',
        'cause': 'เกิดจากการกระจายตัวของอากาศที่มีความชื้นสูงและอุณหภูมิไม่สูงมาก',
        'weather_impact': 'มักไม่ทำให้ฝนตกหนัก แต่จะมีการปกคลุมท้องฟ้าด้วยเมฆที่หนา',
        'image_url': 'assets/stratocumulus.jpg',
      },
      {
        'name': 'altocumulus',
        'description': 'เมฆอัลโตคิวมูลัสมีลักษณะเป็นหย่อมสีขาวหรือสีเทากระจายทั่วท้องฟ้าเป็นก้อนกลมขนาดใหญ่',
        'formation': 'พบในช่วงฤดูร้อนหรือในช่วงเช้าที่มีอากาศอบอุ่นและชื้น',
        'atmospheric_layer': 'ชั้นบรรยากาศกลาง (2,000 - 6,000 เมตร)',
        'cause': 'เกิดจากการลอยตัวของอากาศที่มีความชื้นสูงที่เกิดจากการระเหยในบรรยากาศ',
        'weather_impact': 'บ่งบอกถึงอากาศอบอุ่นและอาจจะมีพายุฝนฟ้าคะนองในช่วงบ่าย',
        'image_url': 'assets/altocumulus.jpg',
      },
      {
        'name': 'nimbostratus',
        'description': 'เมฆนิมโบสเตรตัสมีลักษณะเป็นชั้นเมฆสีเทาเข้มที่แผ่ขยายจากชั้นบรรยากาศต่ำและกลาง',
        'formation': 'เป็นเมฆฝนที่มักเกิดในพื้นที่กว้างเมื่อมีฝนตกหรือหิมะตก',
        'atmospheric_layer': 'ชั้นบรรยากาศต่ำถึงกลาง',
        'cause': 'เกิดจากการสะสมของความชื้นในบรรยากาศที่มีการเย็นตัวลง',
        'weather_impact': 'เมฆเหล่านี้มีฝนตกหนักหรือละอองหิมะตกได้',
        'image_url': 'assets/nimbostratus.jpg',
      },
      {
        'name': 'altostratus',
        'description': 'เมฆอัลโตสเตรตัสเป็นแผ่นเมฆสีเทาหรือสีเทาอมฟ้าที่ปกคลุมท้องฟ้า',
        'formation': 'ปกคลุมท้องฟ้าและมักเกิดก่อนแนวปะทะอากาศอุ่นหรืออากาศปิด',
        'atmospheric_layer': 'ชั้นบรรยากาศกลาง (2,000 - 6,000 เมตร)',
        'cause': 'เกิดจากความชื้นสะสมในชั้นบรรยากาศที่มีอุณหภูมิอ่อน',
        'weather_impact': 'ช่วยบ่งบอกถึงการเปลี่ยนแปลงในสภาพอากาศ เช่น การเข้าสู่สภาพอากาศที่มีอากาศอุ่นหรือมีความชื้น',
        'image_url': 'assets/altostratus.jpg',
      },
      {
        'name': 'cirrus',
        'description': 'เมฆเซอร์รัสเป็นเมฆสีขาวบาง ๆ ที่ทอดยาวพาดผ่านท้องฟ้า',
        'formation': 'มักเกิดในช่วงที่อากาศดีและสามารถเห็นในระดับสูง',
        'atmospheric_layer': 'ระดับสูง (มากกว่า 20,000 ฟุต)',
        'cause': 'เกิดจากการระเหยของน้ำในอากาศที่มีความเย็นและไอน้ำในชั้นบรรยากาศสูง',
        'weather_impact': 'เมฆเซอร์รัสสามารถบ่งบอกถึงการเปลี่ยนแปลงของสภาพอากาศ เช่น พายุที่จะเกิดขึ้น',
        'image_url': 'assets/cirrus.jpg',
      },
      {
        'name': 'cirrocumulus',
        'description': 'เมฆเซอร์โรคูมูลัสเป็นเมฆสีขาวขนาดเล็กที่มักเรียงตัวเป็นแถว',
        'formation': 'พบในฤดูหนาวหรือในวันที่อากาศเย็น',
        'atmospheric_layer': 'ระดับสูง (มากกว่า 6,000 เมตร)',
        'cause': 'เกิดจากการลอยตัวของอากาศที่มีความชื้นสูงในระดับสูง',
        'weather_impact': 'มีความสัมพันธ์กับสภาพอากาศที่หนาวเย็นและสัญญาณของสภาพอากาศที่ดี',
        'image_url': 'assets/cirrocumulus.jpg',
      },
      {
        'name': 'cirrostratus',
        'description': 'เมฆเซอร์โรสเตรตัสเป็นเมฆสีขาวใสที่ปกคลุมท้องฟ้าเกือบทั้งหมด',
        'formation': 'บ่งบอกถึงการสะสมของความชื้นในชั้นบรรยากาศสูง',
        'atmospheric_layer': 'ระดับสูง (20,000 ฟุตขึ้นไป)',
        'cause': 'เกิดจากการสะสมของผลึกน้ำแข็งในชั้นบรรยากาศสูง',
        'weather_impact': 'บ่งบอกถึงความชื้นสูงและมีความสัมพันธ์กับมวลอากาศอุ่นที่เคลื่อนตัวเข้ามา',
        'image_url': 'assets/cirrostratus.jpg',
      },
      {
        'name': 'cumulonimbus',
        'description': 'เมฆคิวมูโลนิมบัสเป็นเมฆฝนฟ้าคะนองที่แผ่ขยายในทุกระดับของชั้นบรรยากาศ',
        'formation': 'มักเกิดในสภาพอากาศที่เลวร้าย',
        'atmospheric_layer': 'พบในทุกระดับ (ต่ำ, กลาง, สูง)',
        'cause': 'เกิดจากการพาความร้อนที่มีความชื้นสูงและลมที่รุนแรง',
        'weather_impact': 'มีฝนตกหนัก, ลูกเห็บ, พายุทอร์นาโด และอากาศไม่ดีทั่วไป',
        'image_url': 'assets/cumulonimbus.jpg',
      },
    ];

    for (var cloud in clouds) {
      await db.insert('clouds', cloud);
    }
  }

  Future<List<CloudInfo>> getAllClouds() async {
    final db = await instance.database;
    final result = await db.query('clouds');
    return result.map((json) => CloudInfo.fromMap(json)).toList();
  }

  Future<CloudInfo?> getCloudByName(String cloudName) async {
    final db = await instance.database;
    final result = await db.query(
      'clouds',
      where: 'name = ?',
      whereArgs: [cloudName],
    );

    if (result.isNotEmpty) {
      return CloudInfo.fromMap(result.first);
    }
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
