<!DOCTYPE html>
<!--
	Tomato GUI
	Copyright (C) 2007-2025 FreshTomato
	ver="v2.74f - 05/26" # rs232
	https://www.freshtomato.org/
	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html lang="en-GB">

<head>
	<meta http-equiv="content-type" content="text/html;charset=utf-8">
	<meta name="robots" content="noindex,nofollow">
	<title>[<% ident(); %>] Advanced: Adblock (DNS filtering)</title>
	<link rel="stylesheet" type="text/css" href="tomato.css?rel=<% version(); %>">
	<% css(); %>
		<style>
			#adblock-status {
				/* dynamic height based on content */
				padding: 20px 6px;
				border: 1px solid rgba(127, 148, 166, 0.25);
				border-radius: 6px;
				/* simple transparent background so table expands with content */
				background: transparent;
				word-break: break-word;
				white-space: normal;
			}

			.adblock-status-head {
				margin-bottom: 4px;
			}

			.adblock-badge {
				display: inline-block;
				margin: 0 6px 0 0;
				padding: 0 8px;
				border-radius: 999px;
				font-size: 11px;
				font-weight: 700;
			}

			.adblock-badge.ok {
				background: #e8f4ea;
				color: #2f7d54;
			}

			.adblock-badge.warn {
				background: #fff3cd;
				color: #9a6b10;
			}

			.adblock-badge.bad {
				background: #fdecea;
				color: #b14b55;
			}

			.adblock-status-view {
				width: 100%;
				border-collapse: collapse;
			}

			.adblock-status-view th,
			.adblock-status-view td {
				padding: 4px 0;
				text-align: left;
				vertical-align: top;
				border-top: 1px solid rgba(127, 148, 166, 0.14);
			}

			.adblock-status-view tr:first-child th,
			.adblock-status-view tr:first-child td {
				border-top: 0;
			}

			.adblock-status-view th {
				width: 110px;
				padding-right: 12px;
				opacity: 0.75;
			}

			.adblock-note {
				display: block;
				margin-top: 0px;
				opacity: 0.85;
			}

			.adblock-note-inline {
				display: inline-block;
				margin-left: 6px;
				opacity: 0.85;
				vertical-align: middle;
			}

			.adblock-bar {
				display: flex;
				align-items: stretch;
				box-sizing: border-box;
				height: 2px;
				margin-top: 2px;
				border-radius: 2px;
				background: rgba(127, 148, 166, 0.22);
				overflow: hidden;
				/* constrain visual width of progress bars */
				max-width: 420px;
				width: 100%;
				font-size: 0;
			}

			.adblock-bar span {
				display: block;
				height: 100%;
				flex: 0 0 auto;
			}

			.adblock-bar span.app {
				background: #005691;
			}

			.adblock-bar span.buffers {
				background: #e3a9d5;
			}

			.adblock-bar span.cache {
				background: #a7d3b6;
			}

			/* buffer/cache specific colours (kept simple) */
			.adblock-bar.buffers span {
				background: #9a6b10;
			}

			.adblock-bar.cache span {
				background: #6c757d;
			}

			.adblock-empty {
				padding-top: 30px;
				text-align: center;
				opacity: 0.72;
			}

			/* owner root special colour (no badge style used elsewhere) */
			.adblock-owner-root {
				color: #9a6b10;
				font-weight: 700;
			}

			/* small spinner used for activity states */
			.adblock-spinner {
				width: 0.5em;
				/* ~50% of the current font-size */
				height: auto;
				vertical-align: middle;
				margin-left: 6px;
				display: inline-block;
			}

			.adblock-spinner-cell {
				margin: 0 auto;
				display: block;
			}

			/* align the middle label column to the right */
			.adblock-status-table .adblock-label {
				text-align: right;
				padding-right: 8px;
			}

			/* ensure header badges and the top status cell are left-aligned */
			.adblock-status-table td.adblock-label[colspan="2"] {
				text-align: left;
				/* override right-align for the top row */
				padding-right: 0;
			}

			.adblock-status-table td:first-child {
				width: 1%;
				white-space: nowrap;
				padding-right: 10px;
			}

			.adblock-status-table td:first-child input[type="button"] {
				width: 11em;
				box-sizing: border-box;
			}

			.adblock-status-table .adblock-td2 {
				width: 100%;
			}

			.adblock-status-table .status-result {
				min-width: 24em;
				min-height: 14px;
				text-align: left;
				font: inherit !important;
			}

			.adblock-status-head {
				text-align: left;
			}

			#adblock-controls {
				display: inline-block;
				width: auto;
			}

			#adblock-grid table {
				table-layout: auto;
			}

			#adblock-grid .co3,
			#adblock-grid .fi3 {
				width: 4ch;
				max-width: 4ch;
				white-space: nowrap;
				text-align: center;
			}

			.adblock-list-size {
				display: inline-block;
				cursor: default;
				text-decoration: underline dotted;
			}

			#adblock-tooltip {
				display: none;
				position: fixed;
				z-index: 9999;
				max-width: 960px;
				min-width: 560px;
				padding: 8px 10px;
				border: 1px solid rgba(127, 148, 166, 0.5);
				border-radius: 4px;
				background: var(--tomato-panel-background, #fff);
				color: var(--tomato-color, inherit);
				box-shadow: 0 4px 12px rgba(0, 0, 0, 0.18);
				font-size: 11px;
				line-height: 1.4;
				text-align: left;
				white-space: normal;
				pointer-events: none;
			}

			#adblock-tooltip pre {
				max-height: none;
				margin: 6px 0 0;
				overflow: visible;
				white-space: pre-wrap;
				word-break: break-word;
			}

			#adblock-delete-dialog {
				display: none;
				position: fixed;
				z-index: 1100;
				left: 50%;
				top: 50%;
				transform: translate(-50%, -50%);
				min-width: 360px;
				max-width: 520px;
				padding: 16px;
				border: 1px solid #8899aa;
				border-radius: 6px;
				background: #fff;
				box-shadow: 0 10px 24px rgba(0, 0, 0, 0.25);
			}

			#adblock-delete-dialog p {
				margin: 0 0 12px;
			}

			#adblock-delete-buttons {
				display: flex;
				gap: 8px;
				justify-content: flex-end;
			}

			#adblock-delete-mask {
				display: none;
				position: fixed;
				inset: 0;
				z-index: 1099;
				background: rgba(0, 0, 0, 0.2);
			}
		</style>
		<script src="tomato.js?rel=<% version(); %>"></script>
		<script src="md5.js?rel=<% version(); %>"></script>
		<script>

			//	<% nvram("adblock_enable,adblock_blacklist,adblock_blacklist_custom,adblock_whitelist,adblock_path,adblock_limit,adblock_logs"); %>

			var cprefix = 'advanced_adblock';
			var adblockg = new TomatoGrid();
			var adblock_refresh = cookie.get(cprefix + '_refresh');
			var cmdresult = '';
			var cmdAction = null;
			var cmdList = null;
			var cmdStatus = null;
			var cmdDelete = null;
			var listSizes = {};
			var listMeta = {};
			var deleteRow = null;
			var deleteDone = null;

			adblockg.exist = function (f, v) {
				var data = this.getAllData();
				for (var i = 0; i < data.length; ++i) {
					if (data[i][f] == v) return true;
				}

				return false;
			}

			adblockg.dataToView = function (data) {
				return [
					(data[0] != '0') ? '&#x2b50' : '',
					escapeHTML(data[1] || ''),
					listSizeToView(data[2], listUrlToHash(data[1])),
					escapeHTML(data[3] || '')
				];
			}

			adblockg.fieldValuesToData = function (row) {
				var f = fields.getAll(row);
				var listSize = row.cells[2] ? row.cells[2].textContent : '';

				return [f[0].checked ? 1 : 0, f[1].value, listSize, f[2].value];
			}

			adblockg.verifyFields = function (row, quiet) {
				var ok = 1;

				return ok;
			}

			function bytesToMB(b) {
				var v = parseInt(b, 10);
				return v > 0 ? (v / 1000000).toFixed(1) : '';
			}

			function listSizeToView(value, md5) {
				var text = String((value == null) ? '' : value), meta;

				if (text === '')
					return '<img src="spin.svg" class="adblock-spinner adblock-spinner-cell" alt="">';

				if (text === '-')
					return '-';

				meta = md5 ? listMeta[md5] : null;
				if (!meta || ((!meta.file) && (!meta.header)))
					return escapeHTML(text);

				return '<span class="adblock-list-size" data-md5="' + escapeHTML(md5) + '">' + escapeHTML(text) + '<\/span>';
			}

			function setListSizeCell(row, value, md5) {
				if (!row || !row._data || !row.cells || (row.cells.length < 3)) return;

				row._data[2] = value;
				row.title = '';
				row.cells[2].title = '';
				row.cells[2].innerHTML = listSizeToView(value, md5);
			}

			function listUrlToHash(url) {
				var normalized = String(url || '').replace(/^[ \t]+/, '').replace(/_$/, '');
				return hex_md5(normalized + '\n').toLowerCase();
			}

			function refreshListSizeCells() {
				var start = adblockg.header ? adblockg.header.rowIndex + 1 : 0;
				var end = adblockg.footer ? adblockg.footer.rowIndex : adblockg.tb.rows.length;

				for (var i = start; i < end; ++i) {
					var row = adblockg.tb.rows[i];
					if (!row || !row._data) continue;

					var md5 = listUrlToHash(row._data[1]);
					var value = listSizes.hasOwnProperty(md5) ? bytesToMB(listSizes[md5]) : '-';
					if (value === '') value = '-';

					setListSizeCell(row, value, md5);
				}
			}

			function decodeListInfoField(value) {
				try {
					return decodeURIComponent(String(value || ''));
				}
				catch (ex) {
					return String(value || '');
				}
			}

			function formatCount(value) {
				var text = String(value == null ? '' : value).replace(/[^0-9-]/g, '');
				if (text === '' || isNaN(text)) return '0';
				return String(parseInt(text, 10)).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
			}

			function adblockDeleteRow(row, done) {
				var md5, meta;

				if (!row || !row._data) return;
				md5 = listUrlToHash(row._data[1]);
				meta = listMeta[md5] || {};

				if ((!meta.file) && (!meta.header)) {
					done();
					return;
				}

				deleteRow = row;
				deleteDone = done;
				E('adblock-delete-mask').style.display = 'block';
				E('adblock-delete-dialog').style.display = 'block';
			}

			function adblockDeleteChoice(mode) {
				var md5, c;

				if (!deleteRow || !deleteDone) return;
				E('adblock-delete-dialog').style.display = 'none';
				E('adblock-delete-mask').style.display = 'none';

				if (mode == 3) {
					deleteRow = null;
					deleteDone = null;
					return;
				}

				if (mode == 2) {
					deleteDone();
					deleteRow = null;
					deleteDone = null;
					return;
				}

				md5 = listUrlToHash(deleteRow._data[1]);

				if (cmdDelete) return;
				cmdDelete = new XmlHttp();
				cmdDelete.onCompleted = function (text, xml) {
					cmdDelete = null;
					updateListSizes();
					deleteDone();
					deleteRow = null;
					deleteDone = null;
				}
				cmdDelete.onError = function (x) {
					cmdDelete = null;
					deleteDone();
					deleteRow = null;
					deleteDone = null;
				}

				c = '/usr/sbin/adblock list-size delete ' + md5;
				cmdDelete.post('shell.cgi', 'action=execute&nojs=1&command=' + escapeCGI(c.replace(/\r/g, '')));
			}

			adblockg.rpDel = function (e) {
				var row = PR(e);
				var me = TGO(row);

				me.moving = null;
				adblockDeleteRow(row, function () {
					row.parentNode.removeChild(row);
					me.recolor();
					me.rpHide();
				});
			}

			adblockg.onDelete = function () {
				var me = this;

				adblockDeleteRow(this.source, function () {
					me.removeEditor();
					elem.remove(me.source);
					me.source = null;
					me.disableNewEditor(false);
					me.clearTextarea();
				});
			}

			function mbToBytes(m) {
				const v = parseFloat(String(m || '').trim());
				// Use decimal MB (1 MB = 1,000,000 bytes)
				return v > 0 ? Math.round(v * 1000000) : ''
			}

			function parseStatusData(text) {
				var data = {};
				var lines = String(text || '').split(/\r?\n/);

				for (var i = 0; i < lines.length; ++i) {
					var pos = lines[i].indexOf('=');
					if (pos > 0)
						data[lines[i].substring(0, pos)] = lines[i].substring(pos + 1);
				}

				return data;
			}

			function statusBadge(label, mode) {
				return '<span class="adblock-badge ' + mode + '">' + escapeHTML(label) + '<\/span>';
			}

			function statusBar(value) {
				var n = parseInt(value, 10);

				if (isNaN(n) || (n < 0)) n = 0;
				if (n > 100) n = 100;
				return '<div class="adblock-bar"><span class="app" style="width:' + n + '%"><\/span><\/div>';
			}


			function statusBarComposite(totalKB, appKB, bufKB, cacheKB) {
				var t = parseInt(totalKB || 0, 10);
				var a = Math.max(0, parseInt(appKB || 0, 10));
				var b = Math.max(0, parseInt(bufKB || 0, 10));
				var c = Math.max(0, parseInt(cacheKB || 0, 10));
				// if total not provided, fall back to sum of segments so percentages can be computed
				if (!t) {
					var sum = a + b + c;
					if (sum > 0) t = sum; else return '';
				}
				var aPct = Math.round(a * 100 / t);
				var bPct = Math.round(b * 100 / t);
				var cPct = Math.round(c * 100 / t);
				// ensure total not exceeding 100
				if (aPct + bPct + cPct > 100) {
					var over = (aPct + bPct + cPct) - 100;
					if (cPct >= over) cPct -= over; else if (bPct >= over) bPct -= over; else aPct -= over;
				}
				var html = '<div class="adblock-bar">';
				if (aPct > 0) html += '<span class="app" style="width:' + aPct + '%"><\/span>';
				if (bPct > 0) html += '<span class="buffers" style="width:' + bPct + '%"><\/span>';
				if (cPct > 0) html += '<span class="cache" style="width:' + cPct + '%"><\/span>';
				html += '<\/div>';
				return html;
			}
			function statusRow(label, value, note, bar) {
				return '<tr><th>' + escapeHTML(label) + '<\/th><td>' + escapeHTML(value)
					+ (note ? '<span class="adblock-note">' + escapeHTML(note) + '<\/span>' : '')
					+ (bar || '') + '<\/td><\/tr>';
			}

			function verifyFields(focused, quiet) {
				var ok = 1;
				cookie.set(cprefix + '_refresh', adblock_refresh);

				return ok;
			}

			var ref = new TomatoRefresh(' ', ' ', 3, 'advanced_adblock_refresh');
			ref.refresh = function (text) {
				try {
					eval(text);
				}
				catch (ex) {
				}
				adblockStatus();
				updateListSizes();
			}

			adblockg.resetNewEditor = function () {
				var f;

				f = fields.getAll(this.newEditor);
				ferror.clearAll(f);
				f[0].checked = 1;
				f[1].value = '';
				if (this.newEditor && this.newEditor.cells[2]) this.newEditor.cells[2].innerHTML = '';
				f[2].value = '';
			}

			adblockg.setup = function () {
				this.init('adblock-grid', '', 50, [
					{ type: 'checkbox', prefix: '<div class="centered">', suffix: '<\/div>' },
					{ type: 'text', maxlen: 130 },
					{ type: 'custom', custom: '<span class="fi3" style="display:block;margin:0 auto"><\/span>' },
					{ type: 'text', maxlen: 40 }
				]);
				this.headerSet(['On', 'Blacklist URL', 'MB', 'Description']);
				var s = nvram.adblock_blacklist.split('>');
				for (var i = 0; i < s.length; ++i) {
					var t = s[i].split('<');
					if (t.length == 3) this.insertData(-1, [t[0], t[1], '', t[2]]);
				}
				this.showNewEditor();
				this.resetNewEditor();
			}

			function save() {
				var data = adblockg.getAllData();
				var blacklist = '';
				for (var i = 0; i < data.length; ++i) {
					blacklist += [data[i][0], data[i][1], data[i][3]].join('<') + '>';
				}

				var fom = E('t_fom');
				fom.adblock_enable.value = E('_f_adblock_enable').checked ? 1 : 0;
				fom.adblock_logs.value = fom.f_adblock_logs.value;
				fom.adblock_limit.value = mbToBytes(fom.f_adblock_limit.value);
				fom.adblock_path.value = fom.f_adblock_path.value.replace(/\/+$/, '');
				fom.adblock_blacklist.value = blacklist;
				form.submit(fom, 1);
				setTimeout(function () { adblockStatus(); }, 2000);
			}

			function init() {
				var c;
				if (((c = cookie.get(cprefix + '_notes_vis')) != null) && (c == '1'))
					toggleVisibility(cprefix, 'notes');

				adblockg.recolor();
				adblockStatus();
				updateListSizes();
				ref.initPage();
				eventHandler();
			}

			function adblockMe(str) {
				if (str == 'snapshot')
					alert('Result saved in /tmp/adblock.snapshot.$now');

				if (cmdAction)
					return;

				cmdAction = new XmlHttp();

				var c = '/usr/sbin/adblock ' + str;
				cmdAction.post('shell.cgi', 'action=execute&command=' + escapeCGI(c.replace(/\r/g, '')));
				cmdAction = null;
				setTimeout(function () { adblockStatus(); }, 500);
			}

			function displayStatus() {
				var s = parseStatusData(cmdresult);
				var blockTone;
				var html;

				if (!s.version) {
					// clear the per-row placeholders (no status)
					for (var i = 1; i <= 8; i++) if (E('adblock-status-' + i)) elem.setInnerHTML(E('adblock-status-' + i), '');
					cmdresult = '';
					return;
				}

				blockTone = (s.block_state == 'Loaded') ? 'ok' : ((s.block_state == 'Parked' || s.block_state == 'Loading') ? 'warn' : 'bad');
				// Compose memory note and small bars for Buffers/Cache
				var memNote = (s.memory_percent || '0') + '% used';
				// build memory bars using raw KB values if provided
				var totalKB = parseInt(s.memory_total_kb || (String(s.memory || '').replace(/.*\/\/(.*) KBytes/, '$1').replace(/[^0-9]/g, '')), 10) || 0;
				var bufKB = parseInt(s.memory_buffers || 0, 10) || 0;
				var cacheKB = parseInt(s.memory_cache || 0, 10) || 0;
				var bufPct = totalKB ? Math.round(bufKB * 100 / totalKB) : 0;
				var cachePct = totalKB ? Math.round(cacheKB * 100 / totalKB) : 0;

				html = '<div class="adblock-status-head">'
					+ statusBadge(s.enabled || 'Disabled', (s.enabled == 'Enabled') ? 'ok' : 'warn')
					+ statusBadge('dnsmasq', (s.dnsmasq == 'Online') ? 'ok' : 'bad')
					+ (s.mapped == 'Yes' ? statusBadge('BlockFile mapped', 'ok') : statusBadge('BlockFile not mapped', 'bad'))
					+ (function () {
						var bs = String(s.block_state || '').trim();
						var blockBadge = '';
						if (bs === 'Loaded') blockBadge = statusBadge('BlockFile loaded', 'ok');
						else if (bs === 'Parked') blockBadge = statusBadge('BlockFile parked', 'warn');
						else if (bs === 'Loading') blockBadge = statusBadge('BlockFile loading', 'warn');
						else blockBadge = statusBadge('BlockFile not loaded', 'bad');
						// Hold badge: if hold is empty or 'Off' -> green ok, otherwise amber warn
						var hold = String(s.hold || '').trim();
						var holdBadge;
						if (hold === '' || /off/i.test(hold)) {
							holdBadge = statusBadge('Hold updates off', 'ok');
						}
						else {
							// If hold contains a minute count like '30 min' or '30 min left', show 'Hold updates for 30 min'
							var m = hold.match(/([0-9]+)\s*min/i);
							if (m) {
								holdBadge = statusBadge('Hold updates for ' + m[1] + ' min', 'warn');
							}
							else {
								holdBadge = statusBadge('Hold updates for ' + escapeHTML(hold), 'warn');
							}
						}
						return blockBadge + holdBadge;
					})()
					+ '<\/div>'
					+ '<table class="adblock-status-view">'
					+ statusRow('Version', s.version || 'N/A', '')
					+ (function () {
						var act = s.activity || 'Idle';
						var mode = (act == 'Idle') ? 'ok' : ((/loading/i.test(act)) ? 'warn' : 'warn');
						var info = s.activity_info ? '<span class="adblock-note-inline">' + escapeHTML(s.activity_info) + '<\/span>' : '';
						// show spinner only for Loading or Checking (case-insensitive)
						var showSpinner = /loading|checking/i.test(act);
						var spinner = showSpinner ? '<img src="spin.svg" class="adblock-spinner" alt="">' : '';
						return '<tr><th>Activity<\/th><td>' + statusBadge(act, mode) + spinner + info + '<\/td><\/tr>';
					})()
					+ (function () {
						var owner = s.owner || 'unknown';
						var mode = (owner == 'root') ? 'bad' : 'ok';
						var ownerDisplay = statusBadge(owner, mode);
						var restarts = escapeHTML(String((s.restarts || '0')));
						return '<tr><th>dnsmasq<\/th><td>' + ownerDisplay + '-<span class="adblock-note-inline">Restarts today: ' + restarts + '<\/span><\/td><\/tr>';
					})()
					+ (function () {
						// Adblock errors and warnings — Warnings: amber/green, Errors: red/green
						var errs = String(s.last_errors || '0');
						var warns = String(s.last_warns || '0');
						function fmtLastRuntime(rt) {
							if (!rt) return 'N/A';
							var h = 0, m = 0, sec = 0;
							var hm = /([0-9]+)h/.exec(rt); if (hm) h = parseInt(hm[1], 10);
							var mm = /([0-9]+)m/.exec(rt); if (mm) m = parseInt(mm[1], 10);
							var sm = /([0-9]+)s/.exec(rt); if (sm) sec = parseInt(sm[1], 10);
							function pad(n) { return (n < 10) ? ('0' + n) : ('' + n); }
							if (h === 0) return pad(m) + 'm ' + pad(sec) + 's';
							return h + 'h ' + pad(m) + 'm ' + pad(sec) + 's';
						}
						var lastRunStr = fmtLastRuntime(s.last_runtime);
						var calls = String(s.calls || '0');
						// choose badge colour: ok when zero, bad otherwise
						var errMode = (parseInt(errs.replace(/[^0-9-]/g, ''), 10) === 0) ? 'ok' : 'bad';
						var warnMode = (parseInt(warns.replace(/[^0-9-]/g, ''), 10) === 0) ? 'ok' : 'warn';
						var errBadge = statusBadge('Errors: ' + errs, errMode);
						var warnBadge = statusBadge('Warnings: ' + warns, warnMode);
						var html = '<tr><th>Adblock<\/th><td>Last run:  ' + escapeHTML(lastRunStr) + ' - ' + escapeHTML(calls) + ' calls today - ' + warnBadge + ' - ' + errBadge + '<\/td><\/tr>';
						return html;
					})()
					+ (function () {
						// robust parsing: prefer explicit keys, else parse s.memory
						var total = parseInt(s.memory_total_kb || 0, 10) || 0;
						var usedKB = parseInt(s.memory_used_kb || 0, 10) || 0;
						if (!total || !usedKB) {
							// try parse s.memory like "used / total KB"
							var m = String(s.memory || '') || '';
							var parts = m.match(/(\d+)\s*\/\s*(\d+)\s*KB/);
							if (parts && parts.length >= 3) {
								usedKB = usedKB || parseInt(parts[1], 10) || 0;
								total = total || parseInt(parts[2], 10) || 0;
							}
						}
						var bufKB = parseInt(String(s.memory_buffers || '0').replace(/,/g, ''), 10) || 0;
						var cacheKB = parseInt(String(s.memory_cache || '0').replace(/,/g, ''), 10) || 0;
						var usedKBClean = parseInt(String(usedKB).replace(/,/g, ''), 10) || 0;
						// Determine app (application) portion. If usedKB is smaller than buf+cache, fall back
						// to treating app as usedKB so it is visible rather than disappearing.
						var appKB = Math.max(0, usedKBClean - bufKB - cacheKB);
						if ((appKB === 0) && (usedKBClean > 0)) appKB = usedKBClean;
						// compute percent
						var pctNum = 0;
						if (total > 0) pctNum = (usedKBClean * 100) / total;
						var pctStr = (Math.round(pctNum * 10) / 10).toFixed(1);

						// helper: format KB -> short MB with one decimal (always show one decimal)
						function fmtKBtoMB(kb) {
							var k = parseInt(kb || 0, 10) || 0;
							var mb = k / 1024;
							var s = (Math.round(mb * 10) / 10).toFixed(1);
							return s + ' MB';
						}

						var usedShort = fmtKBtoMB(usedKBClean);
						var totalShort = fmtKBtoMB(total);
						var bufShort = fmtKBtoMB(bufKB);
						var cacheShort = fmtKBtoMB(cacheKB);

						// New layout: Used: <used> (<pct>%) - Buffers: <buf> - Cache: <cache> / <total>
						var valueStr = 'Used: ' + usedShort + ' (' + pctStr + '%) - Buffers: ' + bufShort + ' - Cache: ' + cacheShort + ' / ' + totalShort;
						return statusRow('Memory', valueStr, '', statusBarComposite(total, appKB, bufKB, cacheKB));
					})()
					+ (function () {
						var refs = s.block_refs || '0 Domains';
						// compute precise percent from numeric sizes
						var sizeNum = parseInt(String(s.block_size || '0').replace(/[^0-9]/g, ''), 10) || 0;
						var limitNum = parseInt(String(s.block_limit || '0').replace(/[^0-9]/g, ''), 10) || 0;
						var pctNumStr = '';
						if (limitNum > 0) {
							var pv = (sizeNum * 100) / limitNum;
							pctNumStr = (Math.round(pv * 10) / 10).toFixed(1) + '%';
						}
						var dateStr = s.block_date ? String(s.block_date) : '';
						// normalize refs to "Domains NNN" format when possible
						var refsMatch = String(refs).match(/^(\s*([0-9,]+)\s*)Domains\s*$/i);
						var refsText = refs;
						if (refsMatch) refsText = 'Domains: ' + refsMatch[2];
						// helper: format bytes into short MB representation
						function fmtMB(bytes) {
							var b = parseInt(bytes || 0, 10) || 0;
							// Use decimal MB (1 MB = 1,000,000 bytes)
							var mb = b / 1000000;
							var s = (Math.round(mb * 10) / 10).toFixed(1);
							if (s.match(/\.0$/)) s = s.replace(/\.0$/, '');
							return s + ' MB';
						}
						var sizeShort = fmtMB(sizeNum);
						var limitShort = (limitNum > 0) ? fmtMB(limitNum) : String(s.block_limit || 'Auto').replace(/Bytes/g, 'B');
						var pctPart = pctNumStr ? (' (' + pctNumStr + ')') : '';
						var datePart = dateStr ? (' | ' + dateStr) : '';
						// New layout: Domains: N | <size> (<pct>) / <limit> | <date>
						return statusRow('Blockfile', refsText + ' | ' + sizeShort + pctPart + ' / ' + limitShort + datePart, '', statusBar(s.block_percent));
					})()
					+ statusRow('Trace', s.trace || 'Off')
					+ '<\/table>';

				// populate per-row placeholders by parsing the generated html fragment
				try {
					var tmp = document.createElement('div');
					tmp.innerHTML = html;
					var head = tmp.querySelector('.adblock-status-head');
					if (head && E('adblock-status-1')) elem.setInnerHTML(E('adblock-status-1'), head.innerHTML);
					var rows = tmp.querySelectorAll('table.adblock-status-view tr');
					for (var ri = 0; ri < rows.length; ri++) {
						var th = rows[ri].querySelector('th');
						var td = rows[ri].querySelector('td');
						var idx = ri + 2; // map first row -> status-2
						if (!E('adblock-status-' + idx)) continue;
						var content = td ? td.innerHTML : '';
						// Put only the content in the right column to avoid duplicating labels
						elem.setInnerHTML(E('adblock-status-' + idx), content);
					}
				}
				catch (ex) {
					// fallback: set first placeholder to the whole html
					if (E('adblock-status-1')) elem.setInnerHTML(E('adblock-status-1'), html);
				}
				cmdresult = '';
			}

			function adblockStatus() {
				if (cmdStatus) return;

				cmdStatus = new XmlHttp();
				cmdStatus.onCompleted = function (text, xml) {
					eval(text);
					displayStatus();
					cmdStatus = null;
				};
				cmdStatus.onError = function (x) {
					cmdStatus = null;
				};
				var c = '/usr/sbin/adblock status-data';
				cmdStatus.post('shell.cgi', 'action=execute&command=' + escapeCGI(c.replace(/\r/g, '')));
			}

			function updateListSizes() {
				if (cmdList) return;
				cmdList = new XmlHttp();
				cmdList.onCompleted = function (text, xml) {
					var lines = String(text || '').replace(/\r/g, '').split('\n');
					listSizes = {};
					listMeta = {};
					for (var i = 0; i < lines.length; ++i) {
						var line = lines[i].trim();
						if (line === '') continue;

						var parts = line.split('\t');
						if (parts.length >= 2) {
							var md5 = parts[0].toLowerCase();
							listSizes[md5] = parts[1];
							listMeta[md5] = {
								bytes: parts[1],
								lines: parts[2] || '0',
								file: decodeListInfoField(parts[3] || ''),
								header: decodeListInfoField(parts[4] || ''),
								mtime: decodeListInfoField(parts[5] || '')
							};
						}
					}
					refreshListSizeCells();
					cmdList = null;
				}
				cmdList.onError = function (x) {
					listSizes = {};
					listMeta = {};
					refreshListSizeCells();
					cmdList = null;
				}
				var c = '/usr/sbin/adblock list-size';
				cmdList.post('shell.cgi', 'action=execute&nojs=1&command=' + escapeCGI(c.replace(/\r/g, '')));
			}

			function earlyInit() {
				adblockg.setup();
				verifyFields(null, true);
				insOvl();
			}

			/* Determine Delimiter/Separator */
			function determineDelimiter(inputString) {
				const lines = inputString.split(/\r?\n/);
				let isSpaceDelimited = false;
				var i = 0
				for (const line of lines) {
					const trimmedLine = line.trim();
					if (trimmedLine.startsWith('#') || trimmedLine === '') {
						continue;
					}
					const units = trimmedLine.split(' ');
					if (units.length > 1)
						return ' ';
					else if (i > 1)
						return '\n';

					i += 1;
				}
			}

			/* Sort Domains */
			function sortDomains(element) {
				var textarea = E(element);
				var delimiter = determineDelimiter(textarea.value.trim());
				var splitDomains = textarea.value.split(delimiter).map((domain) => domain.trim().split(".").reverse());
				const regex = /[%!#+\s]/g
				splitDomains.sort((a, b) => {
					var aList = a.map(item => item.replace(regex, ''));
					var bList = b.map(item => item.replace(regex, ''));
					var aSeg = aList[1], bSeg = bList[1];

					if (aSeg === undefined || bSeg === undefined) { return 0; }
					if (a.length > 2 && aList[0].length === 2 && aSeg.length <= 3)
						aSeg = aList[2];

					if (b.length > 2 && bList[0].length === 2 && bSeg.length <= 3)
						bSeg = bList[2];

					var domainCompare = aSeg.toLowerCase().localeCompare(bSeg.toLowerCase());
					if (domainCompare !== 0) return domainCompare;

					var tldCompare = aList[0].toLowerCase().localeCompare(bList[0].toLowerCase());
					if (tldCompare !== 0) return tldCompare;

					var i = 1;
					while (true) {
						var aSeg = aList[i], bSeg = bList[i];

						if (aSeg === undefined && bSeg === undefined)
							return 0;
						else if (aSeg === undefined)
							return -1;
						else if (bSeg === undefined)
							return 1;

						var subCompare = aSeg.toLowerCase().localeCompare(bSeg.toLowerCase());
						if (subCompare !== 0) return subCompare;

						i += 1;
					}
				});
				var sortedDomains = splitDomains.map((segments) => segments.reverse().join("."));
				textarea.value = sortedDomains.join(delimiter).trim();
			}

			function eventHandler() {
				var tooltip = E('adblock-tooltip');
				if (!tooltip) return;

				document.addEventListener('mouseover', function (e) {
					var t = e.target;
					while (t && t.nodeType === 1) {
						if (t.className && ((' ' + t.className + ' ').indexOf(' adblock-list-size ') >= 0)) {
							var md5 = t.getAttribute('data-md5');
							if (md5 && listMeta[md5]) {
								var meta = listMeta[md5];
								tooltip.innerHTML = '<div><b>File<\/b>: ' + escapeHTML(meta.file || (md5 + '.list')) + '<\/div>'
									+ (meta.mtime ? '<div><b>Date<\/b>: ' + escapeHTML(meta.mtime) + '<\/div>' : '')
									+ '<div><b>Size<\/b>: ' + formatCount(meta.bytes || '0') + ' B<\/div>'
									+ '<div><b>Lines<\/b>: ' + formatCount(meta.lines || '0') + '<\/div>'
									+ (meta.header ? '<div><b>.header<\/b><\/div><pre>' + escapeHTML(meta.header) + '<\/pre>' : '');
								tooltip.style.display = 'block';
								var rect = t.getBoundingClientRect();
								var tw = tooltip.offsetWidth || 560;
								var th = tooltip.offsetHeight;
								var top = rect.top + rect.height / 2 - th / 2;
								var left = rect.left - tw - 10;
								if (left < 4) left = rect.right + 10;
								if (top < 4) top = 4;
								var maxTop = window.innerHeight - th - 4;
								if (top > maxTop) top = maxTop;
								tooltip.style.top = Math.max(4, top) + 'px';
								tooltip.style.left = Math.max(4, left) + 'px';
							}
							return;
						}
						t = t.parentNode;
					}
				});

				document.addEventListener('mouseout', function (e) {
					var t = e.target;
					while (t && t.nodeType === 1) {
						if (t.className && ((' ' + t.className + ' ').indexOf(' adblock-list-size ') >= 0)) {
							tooltip.style.display = 'none';
							return;
						}
						t = t.parentNode;
					}
				});
			}

		</script>
</head>

<body onload="init()">
	<form id="t_fom" method="post" action="tomato.cgi">
		<div id="adblock-delete-mask"></div>
		<div id="adblock-delete-dialog">
			<p>Delete list:</p>
			<div id="adblock-delete-buttons">
				<input type="button" value="Remove File and list" onclick="adblockDeleteChoice(1)">
				<input type="button" value="Remove list only" onclick="adblockDeleteChoice(2)">
				<input type="button" value="Cancel" onclick="adblockDeleteChoice(3)">
			</div>
		</div>
		<table id="container">
			<tr>
				<td colspan="2" id="header">
					<div class="title"><a href="/">FreshTomato</a></div>
					<div class="version">Version <% version(); %> on <% nv("t_model_name"); %><span
									class="blinking bl2">
									<script><% anonupdate(); %> anon_update()</script>&nbsp;
								</span></div>
				</td>
			</tr>
			<tr id="body">
				<td id="navi">
					<script>navi()</script>
				</td>
				<td id="content">
					<div id="ident">
						<% ident(); %> |
							<script>wikiLink();</script>
					</div>

					<!-- / / / -->

					<input type="hidden" name="_nextpage" value="advanced-adblock.asp">
					<input type="hidden" name="_service" value="adblock-restart">
					<input type="hidden" name="adblock_enable">
					<input type="hidden" name="adblock_logs">
					<input type="hidden" name="adblock_path">
					<input type="hidden" name="adblock_limit">
					<input type="hidden" name="adblock_blacklist">

					<!-- / / / -->

					<div class="section-title">Adblock (DNS filtering) - Settings</div>
					<div class="section">
						<script>
							createFieldTable('', [
								{ title: 'Enable', name: 'f_adblock_enable', type: 'checkbox', value: nvram.adblock_enable != '0' },
								{ title: 'Max Log Level', indent: 2, name: 'f_adblock_logs', type: 'select', options: [[0, 'Only Basic'], [3, '3 Error (default)'], [4, '4 Warning'], [5, '5 Notification'], [6, '6 Info'], [7, '7 Debug + trace mode']], value: nvram.adblock_logs },
								{ title: 'Blockfile size limit', indent: 2, name: 'f_adblock_limit', type: 'text', placeholder: 'empty = reset', maxlen: 32, size: 15, suffix: '&nbsp;<small>MB<\/small>', value: bytesToMB(nvram.adblock_limit) },
								{ title: 'Custom path (optional)', indent: 2, name: 'f_adblock_path', type: 'text', placeholder: 'empty = /tmp', maxlen: 64, size: 15, suffix: '<small>/adblock/<\/small>', value: nvram.adblock_path }
							]);
						</script>
					</div>

					<!-- / / / -->

					<div class="section-title">Domain blacklist URLs & Group-of-lists</div>
					<div class="section">
						<div class="tomato-grid" id="adblock-grid"></div>
					</div>

					<!-- / / / -->

					<div class="section-title">Domain blacklist custom</div><input type="button"
						value="Sort domains backward a-z ↓" onclick="sortDomains('domain-blacklist')"
						id="sort-button-blacklist" style="float:right">
					<div class="section">
						<script>
							createFieldTable('', [
								{ title: 'Individual domains and/or path to external file/s.<br>Domains defined with a prepending <b>+<\/b> will have any found subdomain pruned from the blockfile.<br>Prepend <b>#<\/b> to comment.', name: 'adblock_blacklist_custom', type: 'textarea', placeholder: 'baddomain.com&#10;/mnt/usb/list-of-bad-domains.list&#10;/mnt/usb/list-of-blacklisted-urls.list&#10;+prune-subdomains.com', value: nvram.adblock_blacklist_custom, id: 'domain-blacklist' }
							]);
						</script>
					</div>

					<!-- / / / -->

					<div class="section-title">Domain whitelist</div>
					<input type="button" value="Sort domains backward a-z ↓" onclick="sortDomains('domain-whitelist')"
						id="sort-button-whitelist" style="float: right;">
					<div class="section">
						<script>
							createFieldTable('', [
								{ title: 'Individual domains and/or path to external file/s.<br>Domains defined with a prepending <b>%<\/b> will not have the own subdomains blocked.<br>Prepend <b>#<\/b> to comment.', name: 'adblock_whitelist', type: 'textarea', placeholder: 'gooddomain.com\&#10;/mnt/usb/list-of-good-domains.list&#10;/mnt/usb/file-cointaining-list-of-urls.list&#10;%onlythis-nosubdomains.com', value: nvram.adblock_whitelist, id: 'domain-whitelist' }
							]);
						</script>
					</div>

					<!-- / / / -->

					<div class="section-title">Adblock Controls / Status</div>
					<div class="section">
						<div class="fields">
							<table class="adblock-status-table">
								<tr valign="top">
									<td valign="top">
										<input type="button" value="▶️ Load" id="adblock-start"
											onclick="adblockMe('start');">
									</td>
									<td class="adblock-label" valign="top" colspan="2">
										<div id="adblock-status-1" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="⏏️ Unload" id="adblock-stop"
											onclick="adblockMe('stop');"></td>
									<td class="adblock-label" valign="top">Version</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-2" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="🔄 Update" id="adblock-update"
											onclick="adblockMe('update');"></td>
									<td class="adblock-label" valign="top">Activity</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-3" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="♻️ Reset limit" id="adblock-reset"
											onclick="adblockMe('reset');"></td>
									<td class="adblock-label" valign="top">dnsmasq</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-4" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="🧹 Clear all files" id="adblock-clear"
											onclick="adblockMe('clear');"></td>
									<td class="adblock-label" valign="top">Adblock</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-5" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="📷 Snapshot" id="adblock-snapshot"
											onclick="adblockMe('snapshot');"></td>
									<td class="adblock-label" valign="top">Memory</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-6" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="☑️ Enable only" id="adblock-enable"
											onclick="adblockMe('enable');"></td>
									<td class="adblock-label" valign="top">Blockfile</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-7" class="status-result"></div>
									</td>
								</tr>
								<tr valign="top">
									<td valign="top"><input type="button" value="⬜ Disable only" id="adblock-disable"
											onclick="adblockMe('disable');"></td>
									<td class="adblock-label" valign="top">Trace</td>
									<td class="adblock-td2" valign="top">
										<div id="adblock-status-8" class="status-result"></div>
									</td>
								</tr>


								<tr>
									<td colspan="3" align="right">
										<div id="adblock-controls">
											<script>genStdRefresh(1, 3, 'ref.toggle()')</script>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</div>

					<!-- / / / -->

					<div class="section-title">Notes <small><i><a href="javascript:toggleVisibility(cprefix,'notes');"
									id="toggleLink-notes"><span id="sesdiv_notes_showhide">(Show)</span></a></i></small>
					</div>
					<div class="section" id="sesdiv_notes" style="display:none">
						<ul>
							<li><b>Updated information on tested adblock lists can be found at <a
										href="https://wiki.freshtomato.org/doku.php/adblock_dns_filtering"
										class="new_window">this
										page</a></b></li>
							<li><b>Enable</b> - Used to activate/deactivate the adblock function. When enable is set the
								script runs
								after a save, a manual Load/Update, it autostart at boot and set autoupdate to run daily
								at a random
								time between 3am and 6am (excluding mins 59,00,01).</li>
							<li><b>Blockfile size limit</b> - Displayed in MB (stored in Bytes) and acts as an
								automatically
								calculated hard limit for the dnsmasq.adblock file. This limit can be overwritten
								manually. Removing
								the number and saving will trigger an internal calculation performed at the next run.
							</li>
							<li><b>Custom path</b> - Optional, allows to save the potentially large adblock files on
								permanent
								storage like USB/CIFS/etc. This indirectly also means lower RAM usage and additional
								list control to
								avoid downloads/processing when not necessary.</li>
							<li><b>Blacklist URL & Group-of-lists</b> - Supported blacklist can come in multiple format.
								as long as
								they are text and with maximum one domain reference per line. Empty lines and lines
								starting with
								"#" or "!" are always ignored. A particular note on the Group-of-lists format where the
								content of
								the defined list contains references to external URLs
								e.g.<br><code>[https://provider.com/badaddresses.txt] --> containing a list of URLs</code>.
							</li>
							<li><b>Blacklist Custom</b> - Optional, newline separated: domain1.com domain2.com
								domain3.com. It also
								accepts external files as a source e.g. <code>/mnt/usb/blacklist</code>, with one domain
								per line.
								Prepending a '+' to the domain will force a removal of all the child domains from the
								blocklist file
								keeping only the custom defined one (blocking all its subdomains).</li>
							<li><b>Whitelist</b> - Optional, newline separated: domain1.com domain2.com domain3.com. It
								also accepts
								external files as a source e.g. <code>/mnt/usb/whitelist</code>, with one domain per
								line. Please
								note by default given a domain, any of its subdomains will be whitelisted. To have a
								domain strictly
								whitelisted (subdomains blocked) prepend a <B>%</B> to the domain.</li>
							<li><b>Files</b> - Do not defined your custom files within the adblock folder as this is
								periodically
								cleaned up
							<li><b>Caution</b> - Configuring large blocklists in adblock is not ideal. Add one list at
								the time and
								monitor the RAM usage. There are multiple protections in place but the most important is
								to trim
								down your final blocklist if too many resources are needed, this is reflected in the
								<code>Blockfile size limit</code> field
							</li>
							<li><b>Hold-time</b> - There's a 30 min hold-time between consecutive updates to avoid false
								positive
								calls. This can be manually overridden performing an unload + update</li>
						</ul>
					</div>

					<!-- / / / -->

					<div id="footer">
						<span id="footer-msg"></span>
						<input type="button" value="Save" id="save-button" onclick="save()">
						<input type="button" value="Cancel" id="cancel-button" onclick="reloadPage()">
					</div>
				</td>
			</tr>
		</table>
	</form>
	<div id="adblock-tooltip"></div>
	<script>earlyInit();</script>
</body>

</html>
