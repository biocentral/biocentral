import 'package:flutter/material.dart';

class BiocentralLazyLogsViewer extends StatefulWidget {
  final List<String> logs;
  final double height;
  final int logsPerPage;

  const BiocentralLazyLogsViewer({
    required this.logs, required this.height, super.key,
    this.logsPerPage = 50,
  });

  @override
  _BiocentralLazyLogsViewerState createState() => _BiocentralLazyLogsViewerState();
}

class _BiocentralLazyLogsViewerState extends State<BiocentralLazyLogsViewer> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _loadedLogs = [];
  bool _isLoading = false;
  int _totalLogCount = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _totalLogCount = widget.logs.length;
    _loadMoreLogs();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant BiocentralLazyLogsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.logs.length != oldWidget.logs.length) {
      _totalLogCount = widget.logs.length;
      _loadMoreLogs();
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreLogs();
    }
  }

  void _loadMoreLogs({bool all = false}) {
    if (!_isLoading && _loadedLogs.length < _totalLogCount) {
      setState(() {
        _isLoading = true;
      });

      final int start = _loadedLogs.length;
      final int end = all ? _totalLogCount : (start + widget.logsPerPage).clamp(0, _totalLogCount);
      _loadedLogs.addAll(widget.logs.sublist(start, end));

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _jumpToBottom() {
    _loadMoreLogs(all: true);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  List<String> get _filteredLogs {
    if (_searchQuery.isEmpty) return _loadedLogs;
    return _loadedLogs.where((log) => log.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Widget _buildLogList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredLogs.length + 1,
      itemBuilder: (context, index) {
        if (index == _filteredLogs.length) {
          return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox();
        }
        return Text(_filteredLogs[index], maxLines: 2, overflow: TextOverflow.ellipsis);
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: Theme.of(context).textTheme.labelMedium,
      decoration: const InputDecoration(
        hintText: 'Search logs...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              _buildLogList(),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: _jumpToBottom,
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}