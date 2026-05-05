class FeaturedBook {
  final int id;
  final String title;
  final String author;
  final String coverAsset;

  const FeaturedBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverAsset,
  });
}

class FeaturedBookData {
  static final List<FeaturedBook> books = [
    const FeaturedBook(id: 1, title: '三体', author: '刘慈欣', coverAsset: 'assets/img/40.jpg'),
    const FeaturedBook(id: 2, title: '活着', author: '余华', coverAsset: 'assets/img/41.jpg'),
    const FeaturedBook(id: 3, title: '百年孤独', author: '加西亚·马尔克斯', coverAsset: 'assets/img/42.jpg'),
    const FeaturedBook(id: 4, title: '平凡的世界', author: '路遥', coverAsset: 'assets/img/43.jpg'),
    const FeaturedBook(id: 5, title: '围城', author: '钱锺书', coverAsset: 'assets/img/44.jpg'),
    const FeaturedBook(id: 6, title: '白夜行', author: '东野圭吾', coverAsset: 'assets/img/45.jpg'),
    const FeaturedBook(id: 7, title: '解忧杂货店', author: '东野圭吾', coverAsset: 'assets/img/46.jpg'),
    const FeaturedBook(id: 8, title: '小王子', author: '圣埃克苏佩里', coverAsset: 'assets/img/47.jpg'),
    const FeaturedBook(id: 9, title: '傲慢与偏见', author: '简·奥斯汀', coverAsset: 'assets/img/48.jpg'),
    const FeaturedBook(id: 10, title: '简·爱', author: '夏洛蒂·勃朗特', coverAsset: 'assets/img/49.jpg'),
    const FeaturedBook(id: 11, title: '呼啸山庄', author: '艾米莉·勃朗特', coverAsset: 'assets/img/50.jpg'),
    const FeaturedBook(id: 12, title: '飘', author: '玛格丽特·米切尔', coverAsset: 'assets/img/51.jpg'),
    const FeaturedBook(id: 13, title: '了不起的盖茨比', author: '菲茨杰拉德', coverAsset: 'assets/img/52.jpg'),
    const FeaturedBook(id: 14, title: '老人与海', author: '海明威', coverAsset: 'assets/img/53.jpg'),
    const FeaturedBook(id: 15, title: '麦田里的守望者', author: '塞林格', coverAsset: 'assets/img/54.jpg'),
    const FeaturedBook(id: 16, title: '1984', author: '乔治·奥威尔', coverAsset: 'assets/img/55.jpg'),
    const FeaturedBook(id: 17, title: '动物农场', author: '乔治·奥威尔', coverAsset: 'assets/img/56.jpg'),
    const FeaturedBook(id: 18, title: '美丽新世界', author: '赫胥黎', coverAsset: 'assets/img/57.jpg'),
    const FeaturedBook(id: 19, title: '局外人', author: '加缪', coverAsset: 'assets/img/58.jpg'),
    const FeaturedBook(id: 20, title: '鼠疫', author: '加缪', coverAsset: 'assets/img/59.jpg'),
    const FeaturedBook(id: 21, title: '霍乱时期的爱情', author: '加西亚·马尔克斯', coverAsset: 'assets/img/60.jpg'),
    const FeaturedBook(id: 22, title: '追风筝的人', author: '卡勒德·胡赛尼', coverAsset: 'assets/img/61.jpg'),
    const FeaturedBook(id: 23, title: '灿烂千阳', author: '卡勒德·胡赛尼', coverAsset: 'assets/img/62.jpg'),
    const FeaturedBook(id: 24, title: '月亮与六便士', author: '毛姆', coverAsset: 'assets/img/63.jpg'),
    const FeaturedBook(id: 25, title: '刀锋', author: '毛姆', coverAsset: 'assets/img/64.jpg'),
    const FeaturedBook(id: 26, title: '人性的枷锁', author: '毛姆', coverAsset: 'assets/img/65.jpg'),
    const FeaturedBook(id: 27, title: '红与黑', author: '司汤达', coverAsset: 'assets/img/66.jpg'),
    const FeaturedBook(id: 28, title: '白夜', author: '陀思妥耶夫斯基', coverAsset: 'assets/img/67.jpg'),
    const FeaturedBook(id: 29, title: '诗经', author: '佚名', coverAsset: 'assets/img/68.jpg'),
    const FeaturedBook(id: 30, title: '唐诗三百首', author: '蘅塘退士', coverAsset: 'assets/img/69.jpg'),
  ];
}
