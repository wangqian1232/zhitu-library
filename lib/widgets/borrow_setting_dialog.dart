import 'package:flutter/material.dart';
import '../services/system_settings_service.dart';
import '../services/system_log_service.dart';

class BorrowSettingDialog extends StatefulWidget {
  final String title;
  final String currentValue;
  final String unit;
  final IconData icon;
  final Function(String) onSave;
  final SystemLogType logType;
  final String logMessage;

  const BorrowSettingDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.unit,
    required this.icon,
    required this.onSave,
    required this.logType,
    required this.logMessage,
  });

  @override
  State<BorrowSettingDialog> createState() => _BorrowSettingDialogState();
}

class _BorrowSettingDialogState extends State<BorrowSettingDialog> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效值')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.onSave(value);

    SystemLogService().addLog(
      widget.logMessage,
      widget.logType,
      operator: 'admin',
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.title}已更新')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '请输入${widget.title}',
              suffixText: widget.unit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}

class FineSettingDialog extends StatefulWidget {
  final String currentValue;
  final Function(double) onSave;

  const FineSettingDialog({
    super.key,
    required this.currentValue,
    required this.onSave,
  });

  @override
  State<FineSettingDialog> createState() => _FineSettingDialogState();
}

class _FineSettingDialogState extends State<FineSettingDialog> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效值')));
      return;
    }

    final fine = double.tryParse(value);
    if (fine == null || fine < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的金额')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.onSave(fine);

    SystemLogService().addLog(
      '管理员修改了逾期罚款设置为 $fine 元/天',
      SystemLogType.settingChange,
      operator: 'admin',
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('逾期罚款已更新')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('逾期罚款'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '请输入逾期罚款金额',
              suffixText: '元/天',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}
