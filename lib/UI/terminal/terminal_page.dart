import 'dart:async';
import 'dart:io';

import 'package:dartpad_lite/core/services/compiler/terminal_runner.dart';
import 'package:dartpad_lite/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  late Terminal _terminal = _createTerminal();
  TerminalProcess? _session;
  StreamSubscription<String>? _outputSub;
  var _starting = false;
  var _running = false;
  int? _exitCode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    unawaited(_startShellSession());
  }

  @override
  void dispose() {
    unawaited(_disposeSession());
    super.dispose();
  }

  Terminal _createTerminal() {
    final terminal = Terminal(maxLines: 10000);

    terminal.onOutput = (data) {
      _session?.input.add(data);
    };
    terminal.onResize = (cols, rows, _, __) {
      _session?.resize(rows, cols);
    };

    return terminal;
  }

  Future<void> _startShellSession() async {
    if (_starting) return;

    await _disposeSession();

    if (mounted) {
      setState(() {
        _starting = true;
        _running = false;
        _errorText = null;
        _exitCode = null;
      });
    }

    try {
      final session = await startUserShell(
        workingDirectory: Directory.current.path,
      );
      _session = session;
      _outputSub = session.output.listen(
        (output) => _terminal.write(output),
        onError: (Object e, StackTrace s) {
          _terminal.write('\r\n$e\r\n');
        },
      );

      if (mounted) {
        setState(() {
          _starting = false;
          _running = true;
        });
      }

      unawaited(_watchExitCode(session));
    } catch (e) {
      _terminal.write('\r\nFailed to start terminal: $e\r\n');

      if (mounted) {
        setState(() {
          _starting = false;
          _running = false;
          _errorText = e.toString();
        });
      }
    }
  }

  Future<void> _watchExitCode(TerminalProcess session) async {
    final code = await session.exitCode;
    if (!mounted || !identical(_session, session)) return;

    await _outputSub?.cancel();
    _outputSub = null;
    _session = null;

    _terminal.write('\r\n[terminal exited with code $code]\r\n');

    if (mounted) {
      setState(() {
        _running = false;
        _exitCode = code;
      });
    }
  }

  Future<void> _disposeSession() async {
    final sub = _outputSub;
    _outputSub = null;
    if (sub != null) {
      await sub.cancel();
    }

    final session = _session;
    _session = null;
    if (session != null) {
      await session.kill();
    }
  }

  void _clearTerminal() {
    _terminal = _createTerminal();
    setState(() {});
  }

  void _restartTerminal() {
    _terminal = _createTerminal();
    setState(() {});
    unawaited(_startShellSession());
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _starting
        ? 'Starting...'
        : _running
        ? 'Running'
        : _exitCode != null
        ? 'Exited ($_exitCode)'
        : 'Idle';
    final statusColor = _starting
        ? AppColor.warning
        : _running
        ? AppColor.success
        : _errorText != null
        ? AppColor.error
        : AppColor.mainGreyLighter;

    return Scaffold(
      backgroundColor: AppColor.mainGreyBlack,
      body: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.mainGreyDark,
              border: Border(bottom: BorderSide(color: AppColor.mainGrey)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal_rounded, color: AppColor.mainGreyLighter),
                const SizedBox(width: 8),
                Text(
                  'Terminal',
                  style: TextStyle(color: AppColor.mainGreyLighter),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(color: AppColor.mainGreyLighter),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Clear',
                  onPressed: _clearTerminal,
                  icon: Icon(Icons.clear_all, color: AppColor.mainGreyLighter),
                ),
                IconButton(
                  tooltip: 'Restart',
                  onPressed: _restartTerminal,
                  icon: Icon(
                    Icons.restart_alt,
                    color: AppColor.mainGreyLighter,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColor.black,
              alignment: Alignment.topLeft,
              child: TerminalView(
                _terminal,
                autofocus: true,
                backgroundOpacity: 1,
                theme: TerminalThemes.defaultTheme,
                textStyle: const TerminalStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
