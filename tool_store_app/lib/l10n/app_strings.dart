import 'package:tool_store_app/l10n/locale_controller.dart';

/// Centralized UI strings for Indonesian (default) and English.
class AppStrings {
  AppStrings._(this._en);

  final bool _en;

  static AppStrings get current =>
      AppStrings._(LocaleController.instance.isEnglish);

  String _t(String id, String en) => _en ? en : id;

  // —— Common ——
  String get appTitle => _t('Data Tool Monitoring', 'Data Tool Monitoring');
  String get dashboardTitle =>
      _t('Dashboard Tool Monitoring', 'Dashboard Tool Monitoring');
  String get emptyPlaceholder => _t('-', '-');
  String get submit => _t('Kirim', 'Submit');
  String get delete => _t('Hapus', 'Delete');
  String get update => _t('Perbarui', 'Update');
  String get add => _t('Tambah', 'Add');
  String get edit => _t('Ubah', 'Edit');
  String get success => _t('Berhasil', 'Success');
  String get warning => _t('PERINGATAN !', 'WARNING !');
  String get confirm => _t('Konfirmasi', 'Confirm');
  String get processing => _t('Memproses...', 'Processing...');
  String get optionalSuffix => _t(' (opsional)', ' (optional)');
  String get remove => _t('Hapus', 'Remove');
  String get clear => _t('Bersihkan', 'Clear');

  // —— Auth ——
  String get loginSubtitle =>
      _t('Masuk untuk melanjutkan ke dashboard', 'Sign in to continue to the dashboard');
  String get loginAccount => _t('Login Akun', 'Sign In');
  String get username => _t('Username', 'Username');
  String get password => _t('Password', 'Password');
  String get confirmPassword => _t('Konfirmasi Password', 'Confirm Password');
  String get requiredField => _t('Wajib diisi!', 'Required!');
  String get required => _t('Wajib diisi', 'Required');
  String get loading => _t('Memuat...', 'Loading...');
  String get loginButton => _t('MASUK', 'SIGN IN');
  String get checkInternet =>
      _t('Periksa koneksi internet', 'Check internet connection');
  String get serverDown => _t('Server tidak tersedia', 'Server is down');
  String get sessionExpired => _t(
        'Sesi habis atau tidak sah. Silakan login ulang.',
        'Session expired or invalid. Please sign in again.',
      );
  String get splashPreparing =>
      _t('Menyiapkan data sesi dan dashboard...', 'Preparing session and dashboard...');

  // —— Drawer / settings ——
  String get guestUser => _t('PENGGUNA TAMU', 'GUEST USER');
  String get activeAccess => _t('Akses Aktif', 'Active Access');
  String get guestMode => _t('Mode Tamu', 'Guest Mode');
  String get activeAccessDesc => _t(
        'Kelola request tool, user, dan dashboard dengan cepat.',
        'Manage tool requests, users, and dashboard quickly.',
      );
  String get guestModeDesc => _t(
        'Silakan login untuk mengakses seluruh menu aplikasi.',
        'Please sign in to access all app menus.',
      );
  String get pleaseLoginContinue =>
      _t('Silakan login untuk melanjutkan', 'Please sign in to continue');
  String get loadingEllipsis => _t('Memuat…', 'Loading…');
  String get drawerTip => _t(
        'Akses cepat ke dashboard, data tool, riwayat, dan pengaturan user.',
        'Quick access to dashboard, tool data, history, and user settings.',
      );
  String get incompleteUserData => _t(
        'Data pengguna tidak lengkap. Silakan login ulang.',
        'User data is incomplete. Please sign in again.',
      );
  String get mainMenu => _t('Menu Utama', 'Main Menu');
  String get account => _t('Akun', 'Account');
  String get appearance => _t('Tampilan', 'Appearance');
  String get darkMode => _t('Mode Gelap', 'Dark Mode');
  String get darkModeOn => _t(
        'Tampilan gelap aktif. Ketuk untuk mode terang.',
        'Dark theme is on. Tap for light theme.',
      );
  String get darkModeOff => _t(
        'Aktifkan tampilan gelap untuk kenyamanan malam hari.',
        'Enable dark theme for comfortable night viewing.',
      );
  String get language => _t('Bahasa', 'Language');
  String get languageId => _t(
        'Bahasa Indonesia aktif. Ketuk untuk English.',
        'Indonesian is active. Tap for English.',
      );
  String get languageEn => _t(
        'English is active. Ketuk untuk Bahasa Indonesia.',
        'English is active. Tap for Indonesian.',
      );
  String get logout => _t('Keluar', 'Logout');
  String get login => _t('Masuk', 'Login');
  String get logoutDesc => _t(
        'Keluar dari sesi dan hapus data login lokal.',
        'Sign out and clear local login data.',
      );
  String get loginDesc => _t(
        'Masuk untuk membuka seluruh fitur aplikasi.',
        'Sign in to unlock all app features.',
      );
  String get logoutTitle => _t('Keluar', 'Logout');
  String get logoutConfirm =>
      _t('Yakin ingin keluar?', 'Are you sure you want to log out?');
  String get back => _t('Batal', 'Back');
  String get yes => _t('Ya', 'Yes');
  String get cancel => _t('Batal', 'Cancel');
  String get save => _t('Simpan', 'Save');
  String get saveData => _t('Simpan Data', 'Save Data');
  String get updateData => _t('Perbarui Data', 'Update Data');

  // —— Drawer menu ——
  String get dashboard => _t('Dashboard', 'Dashboard');
  String get dashboardSubtitle => _t(
        'Lihat ringkasan aktivitas dan monitoring request.',
        'View activity summary and request monitoring.',
      );
  String get dataTool => _t('Data Tool', 'Data Tool');
  String get dataToolSubtitle => _t(
        'Buka daftar request tool dan detail item pekerjaan.',
        'Open tool request list and job item details.',
      );
  String get completed => _t('Selesai', 'Completed');
  String get completedSubtitle => _t(
        'Lihat item yang sudah selesai diproses.',
        'View items that have been fully processed.',
      );
  String get holdOrder => _t('Hold Order', 'Hold Order');
  String get holdOrderSubtitle => _t(
        'Orderan tidak dilanjutkan oleh Service Admin',
        'Orders not continued by Service Admin',
      );
  String get rejectedSuperior => _t('Ditolak', 'Rejected');
  String get rejectedSuperiorSubtitle => _t(
        'Orderan dibatalkan oleh Foreman / Superior',
        'Orders cancelled by Foreman / Superior',
      );
  String get rejectedDeptHead => _t('Ditolak', 'Rejected');
  String get rejectedDeptHeadSubtitle => _t(
        'Orderan dibatalkan oleh Dept Head',
        'Orders cancelled by Dept Head',
      );
  String get user => _t('User', 'User');
  String get userSubtitle => _t(
        'Kelola data user dan informasi akun.',
        'Manage user data and account information.',
      );

  // —— Dashboard ——
  String get searchResults => _t('Hasil Pencarian', 'Search Results');
  String get draft => _t('Draft', 'Draft');
  String get draftSubtitle => _t(
        'Request baru yang masih perlu dicek.',
        'New requests that still need review.',
      );
  String get superiorApproval => _t('Persetujuan Superior', 'Superior Approval');
  String get superiorApprovalSubtitle => _t(
        'Menunggu persetujuan atasan terkait.',
        'Waiting for related supervisor approval.',
      );
  String get serviceAdmin => _t('Service Admin', 'Service Admin');
  String get serviceAdminSubtitle => _t(
        'Masuk ke proses validasi admin service.',
        'In service admin validation process.',
      );
  String get deptHeadApproval =>
      _t('Persetujuan Dept. Head', 'Dept. Head Approval');
  String get deptHeadApprovalSubtitle => _t(
        'Perlu persetujuan dari kepala departemen.',
        'Requires department head approval.',
      );
  String get counterGaProcessing =>
      _t('Proses Counter / GA', 'Counter / GA Processing');
  String get counterGaProcessingSubtitle => _t(
        'Menunggu proses Counter atau GA.',
        'Waiting for Counter or GA processing.',
      );
  String get toolReceivedWhGa =>
      _t('Tool Diterima di Warehouse / GA', 'Tool Received at Warehouse / GA');
  String get toolReceivedWhGaSubtitle => _t(
        'Tool sudah tiba dan follow up ke Warehouse / GA.',
        'Tool has arrived; follow up with Warehouse / GA.',
      );
  String get viewDetail => _t('Lihat detail', 'View details');

  // —— Search ——
  String get searchFormTitle => _t('Cari Data Form', 'Search Form Data');
  String get searchUserHint => _t('Cari data user...', 'Search user data...');
  String get close => _t('Tutup', 'Close');
  String get searchFormHint => _t('Cari data form...', 'Search form data...');
  String get search => _t('Cari', 'Search');
  String get clearSearch => _t('Hapus pencarian', 'Clear search');
  String get searchNotFoundSuffix => _t('Tidak Ditemukan', 'Not Found');
  String get noRecordDataFound =>
      _t('Tidak Ada Data', 'No Record Data Found');
  String get searchFieldAll => _t('Semua', 'All');
  String get searchFieldFormNo => _t('No. Form', 'Form No');
  String get searchFieldServiceman => _t('Serviceman', 'Serviceman');
  String get searchFieldStatus => _t('Status', 'Status');
  String get searchFieldCategory => _t('Kategori', 'Category');
  String get searchFieldPnGroup => _t('Grup PN', 'PN Group');
  String get searchFieldDescription => _t('Deskripsi', 'Description');
  String get fieldName => _t('Nama', 'Name');
  String get fieldPhone => _t('No. Telp', 'No.Telp');
  String get fieldLevel => _t('Level', 'Level');
  String get fieldId => _t('ID', 'ID');
  String get fieldSuperior => _t('Superior', 'Superior');
  String levelChip(String level) => _t('Level $level', 'Level $level');
  String usersLoadedSummary(int n, int t) =>
      _t('$n dari $t user dimuat', '$n of $t user(s) loaded');
  String usersLoadedCount(int n) =>
      _t('$n user dimuat', '$n user(s) loaded');
  String loadMoreUsers(int size) =>
      _t('Muat $size lagi', 'Load $size more');
  String searchNotFound(String query) => '$query ${searchNotFoundSuffix}';

  Map<String, String> get searchFieldLabels => {
        'all': searchFieldAll,
        'formNo': searchFieldFormNo,
        'serviceman': searchFieldServiceman,
        'status': searchFieldStatus,
        'idForm': searchFieldCategory,
        'pnGroup': searchFieldPnGroup,
        'pnDesc': searchFieldDescription,
      };

  Map<String, String> get userSearchFieldLabels => {
        'all': searchFieldAll,
        'username': username,
        'name': fieldName,
        'phone': fieldPhone,
        'level': fieldLevel,
        'status': searchFieldStatus,
      };

  // —— CRUD titles ——
  String get addData => _t('TAMBAH DATA', 'ADD DATA');
  String get editData => _t('UBAH DATA', 'EDIT DATA');
  String get formUser => _t('FORM USER', 'FORM USER');
  String get dataUser => _t('Data User', 'Data User');
  String get editDataUser => _t('Ubah Data User', 'Edit Data User');
  String get addDataUser => _t('Tambah Data User', 'Add Data User');
  String get userAccountForm =>
      _t('Form Akun User', 'User Account Form');
  String get editDataTool => _t('Ubah Data Tool', 'Edit Data Tool');
  String get addDataTool => _t('Tambah Data Tool', 'Add Data Tool');
  String get toolRequestForm =>
      _t('Form Request Tool', 'Tool Request Form');
  String get addToolItemsTitle =>
      _t('Tambah Item Tool ', 'Add Tool Items ');
  String get editToolItemTitle =>
      _t('Ubah Item Tool', 'Edit Tool Item');
  String get multipleDetailInput =>
      _t('Input Detail Multiple', 'Multiple Detail Input');
  String get singleDetailInput =>
      _t('Input Detail Tunggal', 'Single Detail Input');

  // —— Access ——
  String get accessDenied => _t(
        'Akses ditolak. Menu User hanya untuk pengguna level SUPERADMIN.',
        'Access denied. User menu is for SUPERADMIN level only.',
      );
  String get accessDeniedSessionEnded => _t(
        'Akses ditolak. Menu User hanya untuk SUPERADMIN. Sesi diakhiri — silakan login kembali.',
        'Access denied. User menu is for SUPERADMIN only. Session ended — please sign in again.',
      );
  String get editUserTooltip => _t('Ubah user', 'Edit user');

  // —— User form ——
  String get pickSuperiorTitle => _t('Pilih superior', 'Pick superior');
  String get searchThenTapName => _t(
        'Cari lalu ketuk salah satu nama',
        'Search then tap a name',
      );
  String get searchNameOrUsernameHint =>
      _t('Nama atau username…', 'Name or username…');
  String get noSuperiorData =>
      _t('Belum ada data superior', 'No superior data yet');
  String get noSearchResults => _t(
        'Tidak ada hasil untuk pencarian ini',
        'No results for this search',
      );
  String get userDeletedSuccess =>
      _t('Data user berhasil dihapus', 'User deleted successfully');
  String get userUpdatedSuccess =>
      _t('Data user berhasil diperbarui', 'User updated successfully');
  String get userAddedSuccess =>
      _t('Data user berhasil ditambahkan', 'User added successfully');
  String get userProcessFailed =>
      _t('Gagal memproses data user', 'Failed to process user data');
  String get superiorDataNotLoaded => _t(
        'Data superior belum dimuat',
        'Superior data not loaded yet',
      );
  String get confirmDeleteData =>
      _t('Yakin hapus data?', 'Are you sure delete data?');
  String get deleteDataTooltip => _t('Hapus data', 'Delete data');
  String get userInformationSection =>
      _t('Informasi User', 'User Information');
  String get accessAndRoleSection =>
      _t('Akses & Role', 'Access & Role');
  String get pleaseSelectLevel =>
      _t('Pilih Level!', 'Please select a Level !');
  String get tapToPickSuperior =>
      _t('Ketuk untuk pilih superior', 'Tap to pick superior');
  String get confirmDataCorrectTitle => _t(
        'Pastikan semua data sudah benar',
        'Please make sure all data is correct',
      );
  String get confirmEditData =>
      _t('Yakin ubah data?', 'Are you sure edit data?');
  String get confirmSaveData =>
      _t('Yakin simpan data?', 'Are you sure save data?');
  String get passwordMismatch =>
      _t('Password tidak cocok', 'Password does not match');

  // —— Tool form ——
  String get noUserData =>
      _t('Belum ada data user', 'No user data yet');
  String get failedProcessData =>
      _t('Gagal memproses data', 'Failed process data');
  String deleteFormTitle(String formNo) =>
      _t('Hapus $formNo', 'Delete $formNo');
  String get confirmDeleteThisData => _t(
        'Yakin hapus data ini?',
        'Are you sure delete this data?',
      );
  String get statusHolder => _t('HOLDER', 'HOLDER');
  String get statusNonHolder => _t('NON HOLDER', 'NON HOLDER');
  String get categoryMissing => _t('MISSING', 'MISSING');
  String get categoryDamage => _t('DAMAGE', 'DAMAGE');
  String get categoryAdditional => _t('ADDITIONAL', 'ADDITIONAL');
  String get categoryBudget => _t('BUDGET', 'BUDGET');
  String get categoryNonBudget => _t('NON BUDGET', 'NON BUDGET');
  String get cannotDeleteToolListHasData => _t(
        'Tidak dapat hapus: daftar tool masih ada data',
        'Cannot delete: tool list has data',
      );
  String get requestInformationSection =>
      _t('Informasi Request', 'Request Information');
  String get formNumber => _t('No. Form', 'Form Number');
  String get statusOrder => _t('Status Order', 'Status Order');
  String get pleaseSelect => _t('Pilih!', 'Please select !');
  String get createDate => _t('Tanggal Buat', 'Create Date');
  String get tapToPickServiceman =>
      _t('Ketuk untuk pilih serviceman', 'Tap to pick serviceman');
  String get pickServicemanTitle =>
      _t('Pilih serviceman', 'Pick serviceman');
  String get userDataNotLoaded => _t(
        'Data user belum dimuat',
        'User data not loaded yet',
      );
  String get noMechanicUsers => _t(
        'Tidak ada user dengan level MECHANIC',
        'No users with MECHANIC level',
      );
  String get checkBy => _t('Check By', 'Check By');
  String get tapToPickCheckBy =>
      _t('Ketuk untuk pilih check by', 'Tap to pick check by');
  String get pickCheckByTitle => _t('Pilih check by', 'Pick check by');
  String get noToolKeeperUsers => _t(
        'Tidak ada user dengan level TOOL_KEEPER',
        'No users with TOOL_KEEPER level',
      );
  String get checkDate => _t('Tanggal Check', 'Check Date');

  // —— Tool multiple input ——
  String get actionNoteA =>
      _t('A  = Order Small Tool Account', 'A  = Order Small Tool Account');
  String get actionNoteB =>
      _t('B = Order Rep & Maint Account', 'B = Order Rep & Maint Account');
  String get actionNoteC =>
      _t('C = Charge Personal Account', 'C = Charge Personal Account');
  String get actionNoteD => _t('D = Charge to ...', 'D = Charge to ...');
  String get actionTypeCat => _t('CAT', 'CAT');
  String get actionTypeVendor => _t('VENDOR', 'VENDOR');
  String deleteItemTitle(String name) => _t('Hapus $name', 'Delete $name');
  String get invalidFormIdReopenOrder => _t(
        'ID form tidak valid. Buka ulang dari daftar order.',
        'Invalid form ID. Reopen from the order list.',
      );
  String get loginUserNotFound => _t(
        'User login tidak ditemukan. Silakan login ulang.',
        'Login user not found. Please sign in again.',
      );
  String get processFailed => _t('Proses gagal', 'Process failed');
  String get addToolSuccess =>
      _t('TAMBAH DATA TOOL BERHASIL', 'ADD DATA TOOL SUCCESS');
  String get editToolSuccess =>
      _t('UBAH DATA TOOL BERHASIL', 'EDIT DATA TOOL SUCCESS');
  String get dataAddedSuccess =>
      _t('Data berhasil ditambahkan', 'Data added successfully');
  String get dataUpdatedSuccess =>
      _t('Data berhasil diupdate', 'Data updated successfully');
  String itemSectionTitle(int index, String id) =>
      _t('Item $index - $id', 'Item $index - $id');
  String get pnGroupConsist => _t('PN GROUP CONSIST', 'PN GROUP CONSIST');
  String get qty => _t('QTY', 'QTY');
  String get description => _t('DESKRIPSI', 'DESCRIPTION');
  String get price => _t('HARGA', 'PRICE');
  String get catLocalVendor =>
      _t('CAT / LOCAL VENDOR', 'CAT / LOCAL VENDOR');
  String get explanation => _t('PENJELASAN', 'EXPLANATION');
  String get actionNoteAbcd =>
      _t('ACTION NOTE (A/B/C/D)', 'ACTION NOTE (A/B/C/D)');
  String get addItemRowTooltip => _t('Tambah baris item', 'Add item row');

  // —— Tool data ——
  String get addTool => _t('Tambah Tool', 'Add Tool');
  String get addToolDisabled =>
      _t('Tambah Tool (nonaktif)', 'Add Tool Disabled');
  String get requestOrder => _t('Request Order', 'Request Order');
  String get requestOrderTool => _t('Request Order Tool', 'Request Order Tool');
  String get requestOrderDisabled =>
      _t('Request Order (nonaktif)', 'Request Order Disabled');
  String get waitingConnection =>
      _t('Menunggu koneksi', 'Waiting for connection');
  String get partial => _t('Sebagian', 'Partial');
  String partialWithCount(String count) =>
      _t('Sebagian ($count)', 'Partial ($count)');
  String get completedStatus => _t('SELESAI', 'COMPLETED');
  String get serviceSupportComment =>
      _t('KOMENTAR SERVICE SUPPORT', 'SERVICE SUPPORT COMMENT');
  String get serviceSupportReview =>
      _t('Review Service Support', 'Service Support Review');
  String get serviceSupportReviewDisabled => _t(
        'Review Service Support (nonaktif)',
        'Service Support Review Disabled',
      );
  String get poLockedBeforeSo => _t(
        'Purchase Order hanya dapat diubah sebelum ada Sales Order',
        'Purchase Order can only be changed before a Sales Order exists',
      );
  String get soLockedBeforeWh => _t(
        'Sales Order hanya dapat diubah sebelum ada Date WH Received',
        'Sales Order can only be changed before Date WH Received exists',
      );
  String get whLockedBeforeToolRoom => _t(
        'Date WH Received hanya dapat diubah sebelum ada Date Tool Room Received',
        'Date WH Received can only be changed before Date Tool Room Received exists',
      );
  String get superiorValidation =>
      _t('Validasi Superior', 'Superior Validation');
  String get supervisorApproval =>
      _t('Persetujuan Supervisor / Foreman', 'Supervisor / Foreman Approval');
  String get supervisorComment =>
      _t('Komentar Supervisor / Foreman', 'Supervisor / Foreman Comment');
  String get approved => _t('DISETUJUI', 'APPROVED');
  String get rejected => _t('DITOLAK', 'REJECTED');
  String get approvalRequired =>
      _t('Persetujuan wajib diisi', 'Approval is required');
  String get commentRequired =>
      _t('Komentar wajib diisi', 'Comment is required');
  String get confirmSupervisorValidation => _t(
        'Konfirmasi Validasi Supervisor',
        'Confirm Supervisor Validation',
      );
  String get confirmSupervisorValidationMsg => _t(
        'Ini akan mengirim persetujuan supervisor/foreman untuk request ini.',
        'This will submit supervisor/foreman approval for this request.',
      );
  String get supervisorValidationSaved => _t(
        'Validasi supervisor tersimpan',
        'Supervisor validation saved',
      );
  String get failedSavingValidation => _t(
        'Gagal menyimpan validasi',
        'Failed saving validation',
      );
  String get deptHeadApprovalDialog =>
      _t('Persetujuan Dept Head', 'Dept Head Approval');
  String get serviceDeptHeadApproval =>
      _t('Persetujuan Service Dept. Head', 'Service Dept. Head Approval');
  String get serviceDeptHeadComment =>
      _t('Komentar Service Dept. Head', 'Service Dept. Head Comment');
  String get confirmDeptHeadApproval => _t(
        'Konfirmasi Persetujuan Dept Head',
        'Confirm Dept Head Approval',
      );
  String get confirmDeptHeadApprovalMsg => _t(
        'Ini akan mengirim persetujuan dept head untuk request ini.',
        'This will submit dept head approval for this request.',
      );
  String get deptHeadApprovalSaved => _t(
        'Persetujuan dept head tersimpan',
        'Dept head approval saved',
      );
  String get failedDeptHeadApproval => _t(
        'Gagal menyimpan persetujuan dept head',
        'Failed saving dept head approval',
      );
  String get serviceAdminReview =>
      _t('Review Service Admin / Support', 'Service Admin / Support Review');
  String get continueOrHold => _t('Lanjutkan atau tahan', 'Continue or hold');
  String get continueLabel => _t('LANJUTKAN', 'CONTINUE');
  String get holdLabel => _t('TAHAN', 'HOLD');
  String get serviceAdminComment =>
      _t('Komentar Service Admin / Support', 'Service Admin / Support Comment');
  String get confirmServiceAdminReview => _t(
        'Konfirmasi Review Service Admin',
        'Confirm Service Admin Review',
      );
  String get confirmServiceAdminReviewMsg => _t(
        'Ini akan mengirim review service admin/support untuk request ini.',
        'This will submit service admin/support review for this request.',
      );
  String get serviceAdminReviewSaved => _t(
        'Review service admin tersimpan',
        'Service admin review saved',
      );
  String get failedServiceAdminReview => _t(
        'Gagal menyimpan review service admin',
        'Failed saving service admin review',
      );
  String get requestOrderToolDialog =>
      _t('Request order tool', 'Request order tool');
  String get confirmRequestOrder => _t(
        'Konfirmasi Request Order',
        'Confirm Request Order',
      );
  String get confirmRequestOrderMsg => _t(
        'Kirim request order tool untuk form ini?',
        'Submit the tool order request for this form?',
      );
  String get requestOrderSubmitted => _t(
        'Request order terkirim',
        'Order request submitted',
      );
  String get failedSubmitOrder => _t(
        'Gagal mengirim request order',
        'Failed to submit order request',
      );
  String get updatePurchaseOrder =>
      _t('Perbarui Purchase Order', 'Update Purchase Order');
  String get addPurchaseOrder =>
      _t('Tambah Purchase Order', 'Add Purchase Order');
  String get deletePurchaseOrder =>
      _t('Hapus Purchase Order', 'Delete Purchase Order');
  String get updateSalesOrder => _t(
        'Perbarui Sales Order (SO) / Purchase Request (PR)',
        'Update Sales Order (SO) / Purchase Request (PR)',
      );
  String get addSalesOrder => _t(
        'Tambah Sales Order (SO) / Purchase Request (PR)',
        'Add Sales Order (SO) / Purchase Request (PR)',
      );
  String get deleteSalesOrder => _t(
        'Hapus Sales Order / Purchase Request (SO/PR)',
        'Delete Sales Order / Purchase Request (SO/PR)',
      );
  String get updateDateWhReceived =>
      _t('Perbarui Tanggal WH Received', 'Update Date WH Received');
  String get addDateWhReceived =>
      _t('Tambah Tanggal WH Received', 'Add Date WH Received');
  String get updateDateToolRoomReceived =>
      _t('Perbarui Tanggal Tool Room Received', 'Update Date Tool Room Received');
  String get addDateToolRoomReceived =>
      _t('Tambah Tanggal Tool Room Received', 'Add Date Tool Room Received');
  String get deleteDateWhReceived =>
      _t('Hapus Tanggal WH Received', 'Delete Date WH Received');
  String get deleteDateToolRoomReceived =>
      _t('Hapus Tanggal Tool Room Received', 'Delete Date Tool Room Received');
  String get purchaseOrder => _t('Purchase Order', 'Purchase Order');
  String get salesOrder =>
      _t('Sales Order (SO) / Purchase Request (PR)', 'Sales Order (SO) / Purchase Request (PR)');
  String get dateWhReceived => _t('Tanggal WH Received', 'Date WH Received');
  String get dateToolRoomReceived =>
      _t('Tanggal Tool Room Received', 'Date Tool Room Received');
  String get noDataFound => _t('Data tidak ditemukan', 'No data found');
  String get loadMore => _t('Muat lebih banyak', 'Load more');
  String formsLoadedSummary(int n, int? t) {
    if (t != null) {
      return _t('$n dari $t form dimuat', '$n of $t form(s) loaded');
    }
    return _t('$n form dimuat', '$n form(s) loaded');
  }

  String get continueOrHoldRequired =>
      _t('Lanjutkan atau tahan wajib dipilih', 'Continue or hold is required');
  String get requestOrderOnlyMilestone => _t(
        'Request Order hanya untuk milestone kosong, Draft, atau Check By Tool Store.',
        'Request Order is only for blank milestone, Draft, or Check By Tool Store.',
      );
  String get submitToSuperiorApproval => _t(
        'Kirim ke Superior untuk Persetujuan',
        'Submit To Superior for Approval',
      );
  String get confirmRequestOrderTitle =>
      _t('Konfirmasi request order', 'Confirm request order');
  String get orderRequestSubmitted => _t(
        'Request order terkirim',
        'Order request submitted',
      );
  String get editLabel => _t('Ubah', 'Edit');
  String get deleteLabel => _t('Hapus', 'Delete');
  String get editUnavailable =>
      _t('Ubah tidak tersedia', 'Edit unavailable');
  String get deleteUnavailable =>
      _t('Hapus tidak tersedia', 'Delete unavailable');
  String get addButton => _t('Tambah', 'Add');
  String get deleteFailed => _t('Gagal menghapus', 'Delete failed');
  String get requestFailed => _t('Request gagal', 'Request failed');
  String formDetailLabel(String id) =>
      _t('Detail form: $id', 'Form detail: $id');
  String get dateYyyyMmDd => _t('Tanggal (yyyy-MM-dd)', 'Date (yyyy-MM-dd)');
  String get dateRequired => _t('Tanggal wajib diisi', 'Date is required');
  String get noteSoPr => _t('Catatan SO / PR', 'Note SO / PR');
  String get noFormsMilestoneFilter => _t(
        'Tidak ada form untuk filter milestone ini',
        'No forms match this milestone filter',
      );
  String formsShownSummary(int n, int loaded, int t) =>
      _t('$n ditampilkan · $loaded dari $t form dimuat', '$n shown · $loaded of $t form(s) loaded');
  String formsShownCount(int n, int loaded) =>
      _t('$n ditampilkan · $loaded form dimuat', '$n shown · $loaded form(s) loaded');
  String poLabel(String no) => _t('PO : $no', 'PO : $no');
  String get purchaseOrderUpdated =>
      _t('Purchase order diperbarui', 'Purchase order updated');
  String get purchaseOrderAdded =>
      _t('Purchase order ditambahkan', 'Purchase order added');
  String get purchaseOrderDeleted =>
      _t('Purchase order dihapus', 'Purchase order deleted');
  String get salesOrderUpdated =>
      _t('Sales order diperbarui', 'Sales order updated');
  String get salesOrderAdded =>
      _t('Sales order ditambahkan', 'Sales order added');
  String get salesOrderDeleted => _t(
        'Sales order / Purchase request (SO/PR) dihapus',
        'Sales order / Purchase request (SO/PR) deleted',
      );
  String get whDateUpdated =>
      _t('Tanggal WH received diperbarui', 'WH received date updated');
  String get whDateAdded =>
      _t('Tanggal WH received ditambahkan', 'WH received date added');
  String get toolRoomDateUpdated => _t(
        'Tanggal Tool Room received diperbarui',
        'Tool room received date updated',
      );
  String get toolRoomDateAdded => _t(
        'Tanggal Tool Room received ditambahkan',
        'Tool room received date added',
      );
  String deletePoConfirm(String po) => _t(
        'Yakin hapus PO $po? Data akan dihapus dari server.',
        'Are you sure you want to delete PO $po? This will be removed from the server.',
      );
  String deleteSoConfirm(String so) => _t(
        'Yakin hapus SO/PR $so? Data akan dihapus dari server.',
        'Are you sure you want to delete SO / PR number $so? This will be removed from the server.',
      );
  String deleteWhDateConfirm(String date) => _t(
        'Yakin hapus tanggal WH received $date?',
        'Are you sure you want to delete the WH received date $date?',
      );
  String deleteToolRoomDateConfirm(String date) => _t(
        'Yakin hapus tanggal Tool Room received $date?',
        'Are you sure you want to delete the Tool Room received date $date?',
      );
  String get accessDeniedEditPo => _t(
        'Akses ditolak. Edit PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
        'Access denied. Edit PO is for SUPERADMIN and TOOL_KEEPER only.',
      );
  String get accessDeniedAddPo => _t(
        'Akses ditolak. Tambah PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
        'Access denied. Add PO is for SUPERADMIN and TOOL_KEEPER only.',
      );
  String get accessDeniedDeletePo => _t(
        'Akses ditolak. Hapus PO hanya untuk SUPERADMIN dan TOOL_KEEPER.',
        'Access denied. Delete PO is for SUPERADMIN and TOOL_KEEPER only.',
      );
  String get accessDeniedSo => _t(
        'Akses ditolak. SO/PR hanya untuk SUPERADMIN, COUNTER, dan GA.',
        'Access denied. SO/PR is for SUPERADMIN, COUNTER, and GA only.',
      );
  String get accessDeniedWh => _t(
        'Akses ditolak. Mengubah tanggal WH received hanya untuk SUPERADMIN dan WH.',
        'Access denied. WH received date is for SUPERADMIN and WH only.',
      );
  String get accessDeniedAddWh => _t(
        'Akses ditolak. Menambah tanggal WH received hanya untuk SUPERADMIN dan WH.',
        'Access denied. Add WH received date is for SUPERADMIN and WH only.',
      );
  String get accessDeniedDeleteWh => _t(
        'Akses ditolak. Menghapus tanggal WH received hanya untuk SUPERADMIN dan WH.',
        'Access denied. Delete WH received date is for SUPERADMIN and WH only.',
      );
  String get accessDeniedToolRoom => _t(
        'Akses ditolak. Mengubah tanggal Tool Room received hanya untuk SUPERADMIN dan TOOL_KEEPER.',
        'Access denied. Tool Room received date is for SUPERADMIN and TOOL_KEEPER only.',
      );

  List<(String, String)> get workflowSteps => [
        (_t('1. Permintaan Order', '1. Order Request'),
            _t('Request diajukan.', 'Request submitted.')),
        (_t('2. Persetujuan Order 1', '2. Order Approval 1'),
            _t('Persetujuan superior.', 'Superior approval.')),
        (_t('3. Review Order', '3. Order Review'),
            _t('Review service support.', 'Service support review.')),
        (_t('4. Persetujuan Order 2', '4. Order Approval 2'),
            _t('Persetujuan dept head.', 'Dept. head approval.')),
        (_t('5. Proses Order', '5. Order Processing'),
            _t('Baris tool / pembelian berjalan.', 'Tool lines / purchasing in progress.')),
        (_t('6. WH Received', '6. WH Received'),
            _t('Warehouse menerima.', 'Warehouse received.')),
        (_t('7. Tool Received', '7. Tool Received'),
            _t('Tool room menerima.', 'Tool room received.')),
      ];
}
