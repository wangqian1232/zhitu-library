import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/shared_book_service.dart';
import 'shared_book_success_page.dart';
import 'shared_book_detail_page.dart';

class PublishSharedBookPage extends StatefulWidget {
  final User user;

  const PublishSharedBookPage({super.key, required this.user});

  @override
  State<PublishSharedBookPage> createState() => _PublishSharedBookPageState();
}

class _PublishSharedBookPageState extends State<PublishSharedBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _remarkController = TextEditingController();

  bool _isSubmitting = false;
  String? _coverAsset;
  File? _coverFile;
  BookCondition _selectedCondition = BookCondition.likeNew;
  ShareType _selectedShareType = ShareType.permanent;
  DateTime? _returnDate;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverFile = File(image.path);
        _coverAsset = null;
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      setState(() {
        _returnDate = date;
      });
    }
  }

  Future<void> _submitBook() async {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _publisherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写完整的图书信息')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final book = await SharedBookService().addSharedBook(
        isbn: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        publisher: _publisherController.text.trim(),
        coverAsset: _coverAsset,
        sharerId: widget.user.id,
        sharerName: widget.user.username,
        sharerGrade: '2021级',
        sharerDepartment: '计算机系',
        condition: _selectedCondition,
        shareType: _selectedShareType,
        returnDate: _returnDate,
        remark: _remarkController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SharedBookSuccessPage(book: book),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('提交失败：$e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('发布共享图书'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: '发布新书'),
              Tab(text: '已共享图书'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPublishTab(), _buildSharedBooksList()],
        ),
      ),
    );
  }

  Widget _buildPublishTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCoverSection(),
              const SizedBox(height: 16),
              _buildBookInfoSection(),
              const SizedBox(height: 16),
              _buildConditionSection(),
              const SizedBox(height: 16),
              _buildShareTypeSection(),
              const SizedBox(height: 16),
              _buildRemarkSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildSharedBooksList() {
    final sharedBooks = SharedBookService().getAllSharedBooks();
    final mySharedBooks = sharedBooks
        .where((book) => book.sharerId == widget.user.id)
        .toList();

    if (mySharedBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无共享图书',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '快去发布你的第一本共享图书吧！',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mySharedBooks.length,
      itemBuilder: (context, index) {
        final book = mySharedBooks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SharedBookDetailPage(book: book),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          book.coverAsset != null && book.coverAsset!.isNotEmpty
                          ? Image.asset(
                              book.coverAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.book,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.book,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  book.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(book.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getStatusColor(book.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '索书号: ${book.shelfNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(SharedBookStatus status) {
    switch (status) {
      case SharedBookStatus.pending:
        return '待上架';
      case SharedBookStatus.available:
        return '可借阅';
      case SharedBookStatus.borrowed:
        return '已借出';
      case SharedBookStatus.reserved:
        return '已预约';
      case SharedBookStatus.maintenance:
        return '维护中';
    }
  }

  Color _getStatusColor(SharedBookStatus status) {
    switch (status) {
      case SharedBookStatus.pending:
        return Colors.orange;
      case SharedBookStatus.available:
        return Colors.green;
      case SharedBookStatus.borrowed:
        return Colors.blue;
      case SharedBookStatus.reserved:
        return Colors.purple;
      case SharedBookStatus.maintenance:
        return Colors.grey;
    }
  }

  Widget _buildCoverSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '图书封面',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickCoverImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _coverFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_coverFile!, fit: BoxFit.cover),
                    )
                  : _coverAsset != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(_coverAsset!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('点击上传封面', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '图书信息',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '书名 *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              labelText: '作者 *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _publisherController,
            decoration: InputDecoration(
              labelText: '出版社 *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '图书品相',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildConditionOption(
                  BookCondition.brandNew,
                  '全新',
                  '未拆封',
                  '✨',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConditionOption(
                  BookCondition.likeNew,
                  '九成新',
                  '保存完好',
                  '📖',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConditionOption(
                  BookCondition.hasNotes,
                  '有笔记',
                  '少量划线',
                  '📝',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionOption(
    BookCondition condition,
    String title,
    String desc,
    String emoji,
  ) {
    final isSelected = _selectedCondition == condition;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = condition),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : Colors.black87,
              ),
            ),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTypeSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '共享方式',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildShareTypeOption(
                  ShareType.permanent,
                  '永久捐赠',
                  '书归图书馆',
                  Icons.volunteer_activism,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareTypeOption(
                  ShareType.temporary,
                  '临时寄存',
                  '设定归还时间',
                  Icons.access_time,
                ),
              ),
            ],
          ),
          if (_selectedShareType == ShareType.temporary) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectReturnDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _returnDate != null
                          ? '预计归还：${_returnDate!.year}-${_returnDate!.month.toString().padLeft(2, '0')}-${_returnDate!.day.toString().padLeft(2, '0')}'
                          : '选择预计归还日期（默认1年后）',
                      style: TextStyle(
                        fontSize: 14,
                        color: _returnDate != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShareTypeOption(
    ShareType type,
    String title,
    String desc,
    IconData icon,
  ) {
    final isSelected = _selectedShareType == type;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedShareType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : Colors.black87,
              ),
            ),
            Text(
              desc,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkSection() {
    final remarkLength = _remarkController.text.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备注信息（选填）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _remarkController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '例如："这本书保存得很好，希望能传给下一位爱书的同学。"',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: '$remarkLength/200',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBook,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('确认提交并生成入馆码'),
            ),
          ),
        ],
      ),
    );
  }
}
