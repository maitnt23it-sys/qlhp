class GiangVien {
  final String? id; 
  final String idgv;
  final String fullname;
  final String image; // base64
  final int sumClass;

  GiangVien({
    this.id,
    required this.idgv,
    required this.fullname,
    this.image = '',
    required this.sumClass,
  });

  factory GiangVien.fromJson(Map<String, dynamic> j) => GiangVien(
        id: j['_id'],
        idgv: j['IDGV'] ?? '',
        fullname: j['Fullname'] ?? '',
        image: j['Image'] ?? '',
        sumClass: (j['SumClass'] ?? 0).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'IDGV': idgv,
        'Fullname': fullname,
        'Image': image,
        'SumClass': sumClass,
      };
}
