///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsFailuresEn failures = TranslationsFailuresEn._(_root);
	late final TranslationsFieldsEn fields = TranslationsFieldsEn._(_root);
	late final TranslationsNavigationEn navigation = TranslationsNavigationEn._(_root);
	late final TranslationsOrganizationsEn organizations = TranslationsOrganizationsEn._(_root);
	late final TranslationsSortEn sort = TranslationsSortEn._(_root);
	late final TranslationsSubscriptionsEn subscriptions = TranslationsSubscriptionsEn._(_root);
	late final TranslationsValidationEn validation = TranslationsValidationEn._(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get pageTitle => 'Login';

	/// en: 'Login'
	String get loginButton => 'Login';

	List<String> get loginAsAdminList => [
		'Not a user? ',
		'Login as Administrator',
	];
	List<String> get returnToLoginAsUser => [
		'Not an administrator? ',
		'Login as User',
	];

	/// en: 'Logged in successfully'
	String get loginSuccess => 'Logged in successfully';

	/// en: 'Logout'
	String get logoutButton => 'Logout';

	/// en: 'Are you sure you want to logout?'
	String get logoutConfirm => 'Are you sure you want to logout?';

	/// en: 'Forgot Password?'
	String get forgotPassword => 'Forgot Password?';

	/// en: 'Forgot Password'
	String get forgotPasswordTitle => 'Forgot Password';

	/// en: 'Enter your email address and we'll send you a link to reset your password.'
	String get forgotPasswordSubtitle => 'Enter your email address and we\'ll send you a link to reset your password.';

	/// en: 'Send Reset Link'
	String get sendResetLink => 'Send Reset Link';

	/// en: 'Back to Login'
	String get backToLogin => 'Back to Login';

	/// en: 'Check Your Email'
	String get checkEmail => 'Check Your Email';

	/// en: 'Password reset link has been sent to $email'
	String resetLinkSent({required Object email}) => 'Password reset link has been sent to ${email}';

	/// en: 'Sign in to continue'
	String get signInToContinue => 'Sign in to continue';

	/// en: 'Continue with Google'
	String get continueWithGoogle => 'Continue with Google';

	/// en: 'or'
	String get orDivider => 'or';

	/// en: 'Signing in...'
	String get signingIn => 'Signing in...';

	/// en: 'You're almost there — just warming things up'
	String get almostThereWarmingUp => 'You\'re almost there — just warming things up';

	/// en: 'Powered by HZN Laundry'
	String get poweredBy => 'Powered by HZN Laundry';

	/// en: 'A verification email has been sent to your email address'
	String get verificationEmailSent => 'A verification email has been sent to your email address';

	/// en: 'Continue'
	String get continueButton => 'Continue';

	/// en: 'Change email'
	String get changeEmail => 'Change email';

	/// en: 'Sign in with email code'
	String get signInWithEmailCode => 'Sign in with email code';

	/// en: 'Sign in with password'
	String get signInWithPassword => 'Sign in with password';

	/// en: 'Send code'
	String get sendLoginCode => 'Send code';

	/// en: 'Verify code'
	String get verifyLoginCode => 'Verify code';

	/// en: 'Login code'
	String get enterLoginCode => 'Login code';

	/// en: 'We sent a login code to $email'
	String loginCodeSent({required Object email}) => 'We sent a login code to ${email}';

	/// en: 'Resend code'
	String get resendLoginCode => 'Resend code';

	/// en: 'Resend in ${seconds}s'
	String resendLoginCodeCooldown({required Object seconds}) => 'Resend in ${seconds}s';

	/// en: 'Could not send login code. Try again later.'
	String get loginCodeSendFailed => 'Could not send login code. Try again later.';

	/// en: 'Can't open your workspace'
	String get scopeRecoveryTitle => 'Can\'t open your workspace';

	/// en: 'Your account isn't assigned to an organization yet. Ask an admin to invite you, then try again.'
	String get scopeRecoveryNoMembership => 'Your account isn\'t assigned to an organization yet. Ask an admin to invite you, then try again.';

	/// en: 'Your organization couldn't be loaded. Contact support if this keeps happening.'
	String get scopeRecoveryOrgUnavailable => 'Your organization couldn\'t be loaded. Contact support if this keeps happening.';

	/// en: 'Your organization is missing a URL slug, so the app can't open the dashboard. Contact support.'
	String get scopeRecoveryEmptyOrgSlug => 'Your organization is missing a URL slug, so the app can\'t open the dashboard. Contact support.';

	/// en: 'No branches are available for your organization. Ask an admin to add a branch, then try again.'
	String get scopeRecoveryNoBranch => 'No branches are available for your organization. Ask an admin to add a branch, then try again.';

	/// en: 'Your branch is missing a URL slug, so the app can't open the dashboard. Contact support.'
	String get scopeRecoveryEmptyBranchSlug => 'Your branch is missing a URL slug, so the app can\'t open the dashboard. Contact support.';

	/// en: 'We couldn't open your workspace after login. Retry, or sign out and try again.'
	String get scopeRecoveryGeneric => 'We couldn\'t open your workspace after login. Retry, or sign out and try again.';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'HZN Laundry'
	String get appName => 'HZN Laundry';

	/// en: 'N/A'
	String get placeholderText => 'N/A';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Submit'
	String get submit => 'Submit';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Previous'
	String get previous => 'Previous';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'View All'
	String get viewAll => 'View All';

	/// en: 'See More'
	String get seeMore => 'See More';

	/// en: 'No results found'
	String get noResults => 'No results found';

	/// en: 'No items to display'
	String get emptyList => 'No items to display';

	/// en: 'Discard changes?'
	String get discardChanges => 'Discard changes?';

	/// en: 'You have unsaved changes. Are you sure you want to discard them?'
	String get discardChangesMessage => 'You have unsaved changes. Are you sure you want to discard them?';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Keep Editing'
	String get keepEditing => 'Keep Editing';

	/// en: 'Sort'
	String get sort => 'Sort';

	/// en: 'Full Screen'
	String get fullScreen => 'Full Screen';

	/// en: 'Exit Full Screen'
	String get exitFullScreen => 'Exit Full Screen';
}

// Path: failures
class TranslationsFailuresEn {
	TranslationsFailuresEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong. Please try again.'
	String get generic => 'Something went wrong. Please try again.';

	/// en: 'Network error. Please check your connection.'
	String get networkError => 'Network error. Please check your connection.';

	/// en: 'Server error. Please try again later.'
	String get serverError => 'Server error. Please try again later.';

	/// en: 'You are not authorized to perform this action.'
	String get unauthorized => 'You are not authorized to perform this action.';

	/// en: 'Your session has expired. Please login again.'
	String get sessionExpired => 'Your session has expired. Please login again.';

	/// en: 'The requested resource was not found.'
	String get notFound => 'The requested resource was not found.';

	/// en: 'Invalid request. Please check your input.'
	String get badRequest => 'Invalid request. Please check your input.';

	/// en: 'A conflict occurred. The resource may already exist.'
	String get conflict => 'A conflict occurred. The resource may already exist.';

	/// en: 'Request timed out. Please try again.'
	String get timeout => 'Request timed out. Please try again.';

	/// en: 'No internet connection.'
	String get noInternet => 'No internet connection.';

	/// en: 'Invalid email or password.'
	String get invalidCredentials => 'Invalid email or password.';

	/// en: 'Invalid or expired login code.'
	String get invalidLoginCode => 'Invalid or expired login code.';

	/// en: 'No account for this Google email. Ask an admin to create your user first.'
	String get googleNoAccount => 'No account for this Google email. Ask an admin to create your user first.';

	/// en: 'No account for this email. Ask an admin to create your user first.'
	String get otpNoAccount => 'No account for this email. Ask an admin to create your user first.';

	/// en: 'Could not start Google sign-in. Please try again.'
	String get googleSignInFailed => 'Could not start Google sign-in. Please try again.';

	/// en: 'Your account has been disabled.'
	String get accountDisabled => 'Your account has been disabled.';

	/// en: 'Please verify your email address.'
	String get emailNotVerified => 'Please verify your email address.';

	/// en: 'Too many requests. Please wait a moment.'
	String get tooManyRequests => 'Too many requests. Please wait a moment.';
}

// Path: fields
class TranslationsFieldsEn {
	TranslationsFieldsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Password confirmation'
	String get passwordConfirmation => 'Password confirmation';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Contact Number'
	String get contactNumber => 'Contact Number';

	/// en: 'Address'
	String get address => 'Address';

	/// en: 'Search Fields'
	String get searchFields => 'Search Fields';

	/// en: 'Select which fields to include in your search'
	String get searchFieldsHint => 'Select which fields to include in your search';

	/// en: 'Required'
	String get requiredField => 'Required';

	/// en: 'At least one field required'
	String get atLeastOneRequired => 'At least one field required';

	/// en: 'Receipt Number'
	String get receiptNumber => 'Receipt Number';

	/// en: 'Customer Name'
	String get customerName => 'Customer Name';

	/// en: 'Payment Reference'
	String get paymentRef => 'Payment Reference';

	/// en: 'Notes'
	String get notes => 'Notes';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Payment Filters'
	String get paymentFilters => 'Payment Filters';

	/// en: 'Paid'
	String get paid => 'Paid';

	/// en: 'Unpaid'
	String get unpaid => 'Unpaid';

	/// en: 'Cash'
	String get cash => 'Cash';

	/// en: 'GCash/Bank'
	String get gcashBank => 'GCash/Bank';
}

// Path: navigation
class TranslationsNavigationEn {
	TranslationsNavigationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Shortcuts'
	String get shortcuts => 'Shortcuts';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Show more'
	String get showMore => 'Show more';

	/// en: 'Show less'
	String get showLess => 'Show less';

	/// en: 'Operations'
	String get operations => 'Operations';

	/// en: 'People'
	String get people => 'People';

	/// en: 'Insights'
	String get insights => 'Insights';

	/// en: 'Administration'
	String get administration => 'Administration';

	/// en: 'Collapse navigation'
	String get collapseNav => 'Collapse navigation';

	/// en: 'Expand navigation'
	String get expandNav => 'Expand navigation';

	/// en: 'Dashboard'
	String get dashboard => 'Dashboard';

	/// en: 'Products'
	String get products => 'Products';

	/// en: 'Inventory'
	String get inventory => 'Inventory';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Reports'
	String get reports => 'Reports';

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Roles'
	String get roles => 'Roles';

	/// en: 'Branches'
	String get branches => 'Branches';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Cashier'
	String get sales => 'Cashier';

	/// en: 'Orders'
	String get salesHistory => 'Orders';

	/// en: 'Management'
	String get management => 'Management';

	/// en: 'Organizations'
	String get organizations => 'Organizations';

	/// en: 'Services'
	String get services => 'Services';

	/// en: 'Customers'
	String get customers => 'Customers';

	/// en: 'Employees'
	String get employees => 'Employees';

	/// en: 'System'
	String get system => 'System';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'No Branch'
	String get noBranch => 'No Branch';

	/// en: 'All Branches'
	String get allBranches => 'All Branches';

	/// en: 'Switching branch…'
	String get switchingBranch => 'Switching branch…';

	/// en: 'Switching to $name…'
	String switchingToBranch({required Object name}) => 'Switching to ${name}…';

	/// en: 'Cashier is not available when All Branches is selected. Choose a specific branch to continue.'
	String get posUnavailableAllBranches => 'Cashier is not available when All Branches is selected. Choose a specific branch to continue.';

	/// en: 'This action requires a specific branch. Choose a branch before continuing.'
	String get createUnavailableAllBranches => 'This action requires a specific branch. Choose a branch before continuing.';

	/// en: 'Activities'
	String get activities => 'Activities';

	/// en: 'Search pages'
	String get searchNavHint => 'Search pages';

	/// en: 'Search results'
	String get searchResults => 'Search results';

	/// en: 'No results'
	String get noSearchResults => 'No results';
}

// Path: organizations
class TranslationsOrganizationsEn {
	TranslationsOrganizationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Organizations'
	String get title => 'Organizations';

	/// en: 'Create Organization'
	String get create => 'Create Organization';

	/// en: 'Organizations you're in'
	String get yourOrganizations => 'Organizations you\'re in';

	/// en: 'Your role'
	String get yourRole => 'Your role';

	/// en: 'Switch to this organization'
	String get switchToThis => 'Switch to this organization';

	/// en: 'Current'
	String get current => 'Current';

	/// en: 'Details'
	String get details => 'Details';

	/// en: 'Save details'
	String get saveDetails => 'Save details';

	/// en: 'Invite people'
	String get invitePeople => 'Invite people';

	/// en: 'Email'
	String get inviteEmail => 'Email';

	/// en: 'Role'
	String get inviteRole => 'Role';

	/// en: 'Send invite'
	String get sendInvite => 'Send invite';

	/// en: 'Pending invites for you'
	String get pendingInvites => 'Pending invites for you';

	/// en: 'Pending invites'
	String get pendingOrgInvites => 'Pending invites';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Decline'
	String get decline => 'Decline';

	/// en: 'Revoke'
	String get revoke => 'Revoke';

	/// en: 'You don't belong to any organizations yet.'
	String get noOrganizations => 'You don\'t belong to any organizations yet.';

	/// en: 'Contact your administrator to be invited to an organization.'
	String get contactAdmin => 'Contact your administrator to be invited to an organization.';

	/// en: 'Invite sent'
	String get inviteSent => 'Invite sent';

	/// en: 'Invite accepted'
	String get inviteAccepted => 'Invite accepted';

	/// en: 'Invite declined'
	String get inviteDeclined => 'Invite declined';

	/// en: 'Invite revoked'
	String get inviteRevoked => 'Invite revoked';

	/// en: 'Organization updated'
	String get saveSuccess => 'Organization updated';

	/// en: 'Organization'
	String get switchOrganization => 'Organization';

	/// en: 'Switching organization…'
	String get switchingOrganization => 'Switching organization…';

	/// en: 'Switching to $name…'
	String switchingToOrganization({required Object name}) => 'Switching to ${name}…';

	/// en: 'Set up your organization'
	String get setupTitle => 'Set up your organization';

	/// en: 'Organization details'
	String get stepDetails => 'Organization details';

	/// en: 'Create your first branch'
	String get stepBranch => 'Create your first branch';

	/// en: 'Choose a subscription'
	String get stepSubscription => 'Choose a subscription';

	/// en: 'Invite your team'
	String get stepInvite => 'Invite your team';

	/// en: 'Review & create'
	String get stepReview => 'Review & create';

	/// en: 'Details'
	String get stepDetailsShort => 'Details';

	/// en: 'Branch'
	String get stepBranchShort => 'Branch';

	/// en: 'Plan'
	String get stepSubscriptionShort => 'Plan';

	/// en: 'Team'
	String get stepInviteShort => 'Team';

	/// en: 'Review'
	String get stepReviewShort => 'Review';

	/// en: 'Select a subscription package to continue.'
	String get subscriptionRequired => 'Select a subscription package to continue.';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Create organization'
	String get finish => 'Create organization';

	/// en: 'Add branch'
	String get addBranch => 'Add branch';

	/// en: 'Enter the first branch details to continue.'
	String get branchRequired => 'Enter the first branch details to continue.';

	/// en: 'No branch yet'
	String get noBranchYet => 'No branch yet';

	/// en: 'Organization is ready'
	String get onboardingComplete => 'Organization is ready';

	/// en: 'Operating Hours'
	String get operatingHours => 'Operating Hours';

	/// en: 'Cut-off Time'
	String get cutOffTime => 'Cut-off Time';

	/// en: 'Add invite'
	String get addInvite => 'Add invite';

	/// en: 'No invites queued. You can skip this step.'
	String get noInvitesQueued => 'No invites queued. You can skip this step.';

	/// en: 'Queued invites'
	String get queuedInvites => 'Queued invites';

	/// en: 'Invite added'
	String get inviteQueued => 'Invite added';

	/// en: 'That email is already queued.'
	String get inviteAlreadyQueued => 'That email is already queued.';

	/// en: 'Remove'
	String get removeInvite => 'Remove';

	/// en: '(one) {1 queued invite} (other) {$n queued invites}'
	String reviewInviteCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 queued invite',
		other: '${n} queued invites',
	);

	/// en: '—'
	String get reviewNone => '—';

	/// en: 'Overview'
	String get overviewTab => 'Overview';

	/// en: 'People'
	String get peopleTab => 'People';

	/// en: 'Features'
	String get featuresTab => 'Features';

	/// en: 'Members'
	String get members => 'Members';

	/// en: 'No members found.'
	String get noMembers => 'No members found.';

	/// en: 'Modules'
	String get featuresModules => 'Modules';

	/// en: 'Notifications'
	String get featuresNotifications => 'Notifications';

	/// en: 'Order workflow'
	String get featuresWorkflow => 'Order workflow';

	/// en: 'Consumable usage'
	String get consumableUsage => 'Consumable usage';

	/// en: 'Send order history emails'
	String get sendHistoryEmails => 'Send order history emails';

	/// en: 'Require machine assignment'
	String get requireMachine => 'Require machine assignment';

	/// en: 'Require pack count'
	String get requirePack => 'Require pack count';

	/// en: 'Require storage assignment'
	String get requireStorage => 'Require storage assignment';

	/// en: 'Only organization managers can change these features.'
	String get featuresReadOnly => 'Only organization managers can change these features.';

	/// en: 'Select organization'
	String get selectTitle => 'Select organization';

	/// en: 'Choose which organization you want to work in.'
	String get selectSubtitle => 'Choose which organization you want to work in.';

	/// en: 'Last used'
	String get lastUsed => 'Last used';

	/// en: '(one) {Expiring in 1 day} (other) {Expiring in $n days}'
	String expiringInDays({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Expiring in 1 day',
		other: 'Expiring in ${n} days',
	);

	/// en: 'Expired'
	String get subscriptionExpired => 'Expired';

	/// en: 'Locked'
	String get subscriptionLocked => 'Locked';

	/// en: 'Super Admin'
	String get superAdmin => 'Super Admin';

	/// en: 'Super Admin'
	String get superAdminTitle => 'Super Admin';

	/// en: 'Platform overview across all organizations.'
	String get superAdminSubtitle => 'Platform overview across all organizations.';

	/// en: 'Platform overview'
	String get platformOverview => 'Platform overview';

	/// en: 'All organizations'
	String get allOrganizations => 'All organizations';

	/// en: 'Search organizations'
	String get searchOrganizations => 'Search organizations';

	/// en: 'No organizations yet.'
	String get noOrganizationsYet => 'No organizations yet.';

	/// en: 'No organizations match your search.'
	String get noMatchingOrganizations => 'No organizations match your search.';

	/// en: 'Organizations'
	String get kpiOrganizations => 'Organizations';

	/// en: 'Orders'
	String get kpiOrders => 'Orders';

	/// en: 'Customers'
	String get kpiCustomers => 'Customers';

	/// en: 'Revenue'
	String get kpiRevenue => 'Revenue';

	/// en: 'Branches'
	String get metricBranches => 'Branches';

	/// en: 'Members'
	String get metricMembers => 'Members';

	/// en: 'Orders'
	String get metricOrders => 'Orders';

	/// en: 'Customers'
	String get metricCustomers => 'Customers';

	/// en: 'Onboarded'
	String get onboarded => 'Onboarded';

	/// en: 'Not onboarded'
	String get notOnboarded => 'Not onboarded';

	/// en: 'Could not load organization stats.'
	String get statsLoadError => 'Could not load organization stats.';
}

// Path: sort
class TranslationsSortEn {
	TranslationsSortEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sort By'
	String get sortBy => 'Sort By';

	/// en: 'Direction'
	String get direction => 'Direction';

	/// en: 'Ascending'
	String get ascending => 'Ascending';

	/// en: 'Descending'
	String get descending => 'Descending';

	/// en: 'Date Added'
	String get dateAdded => 'Date Added';

	/// en: 'Last Updated'
	String get lastUpdated => 'Last Updated';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Price'
	String get price => 'Price';

	/// en: 'Stock'
	String get stock => 'Stock';

	/// en: 'Expiration'
	String get expiration => 'Expiration';

	/// en: 'Status'
	String get status => 'Status';
}

// Path: subscriptions
class TranslationsSubscriptionsEn {
	TranslationsSubscriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dashboard'
	String get tabOverview => 'Dashboard';

	/// en: 'Packages'
	String get tabPackages => 'Packages';

	/// en: 'Payments'
	String get tabPayments => 'Payments';

	/// en: 'Billing'
	String get tabBilling => 'Billing';

	/// en: 'Subscription'
	String get subscription => 'Subscription';

	/// en: 'No subscription'
	String get noSubscription => 'No subscription';

	/// en: 'Active'
	String get statusActive => 'Active';

	/// en: 'Grace'
	String get statusGrace => 'Grace';

	/// en: 'Locked'
	String get statusLocked => 'Locked';

	/// en: 'Cancelled'
	String get statusCancelled => 'Cancelled';

	/// en: 'Period ends'
	String get periodEnds => 'Period ends';

	/// en: 'Period start'
	String get periodStart => 'Period start';

	/// en: 'Period end'
	String get periodEnd => 'Period end';

	/// en: 'Leave blank to use today + package interval'
	String get periodDatesHint => 'Leave blank to use today + package interval';

	/// en: 'Start date is required when end date is set'
	String get periodStartRequiredWithEnd => 'Start date is required when end date is set';

	/// en: 'End date must be after start date'
	String get periodEndAfterStart => 'End date must be after start date';

	/// en: 'Grace ends'
	String get graceEnds => 'Grace ends';

	/// en: 'Pending proofs'
	String get pendingProofs => 'Pending proofs';

	/// en: 'Assign package'
	String get assignPackage => 'Assign package';

	/// en: 'Change package'
	String get changePackage => 'Change package';

	/// en: 'Manual unlock'
	String get manualUnlock => 'Manual unlock';

	/// en: 'Lock organization'
	String get manualLock => 'Lock organization';

	/// en: 'Unlock until'
	String get unlockUntil => 'Unlock until';

	/// en: 'Organization unlocked'
	String get unlockSuccess => 'Organization unlocked';

	/// en: 'Could not unlock organization'
	String get unlockFailed => 'Could not unlock organization';

	/// en: 'Organization locked'
	String get lockSuccess => 'Organization locked';

	/// en: 'Could not lock organization'
	String get lockFailed => 'Could not lock organization';

	/// en: 'The organization will be unusable until unlocked or payment is approved. Users can still open the pay screen.'
	String get lockConfirmMessage => 'The organization will be unusable until unlocked or payment is approved. Users can still open the pay screen.';

	/// en: 'Package name'
	String get packageName => 'Package name';

	/// en: 'Description'
	String get packageDescription => 'Description';

	/// en: 'Price (₱)'
	String get packagePrice => 'Price (₱)';

	/// en: 'Every'
	String get intervalCount => 'Every';

	/// en: 'Interval'
	String get intervalUnit => 'Interval';

	/// en: 'Day(s)'
	String get intervalDay => 'Day(s)';

	/// en: 'Month(s)'
	String get intervalMonth => 'Month(s)';

	/// en: 'Year(s)'
	String get intervalYear => 'Year(s)';

	/// en: 'Premade package'
	String get isPremade => 'Premade package';

	/// en: 'Create package'
	String get createPackage => 'Create package';

	/// en: 'Edit package'
	String get editPackage => 'Edit package';

	/// en: 'Delete package'
	String get deletePackage => 'Delete package';

	/// en: 'Package created'
	String get packageCreated => 'Package created';

	/// en: 'Package updated'
	String get packageUpdated => 'Package updated';

	/// en: 'Package deleted'
	String get packageDeleted => 'Package deleted';

	/// en: 'No packages yet.'
	String get noPackages => 'No packages yet.';

	/// en: 'Select a package'
	String get selectPackage => 'Select a package';

	/// en: 'Custom package'
	String get customPackage => 'Custom package';

	/// en: 'Subscription assigned'
	String get assignSuccess => 'Subscription assigned';

	/// en: 'Could not assign subscription'
	String get assignFailed => 'Could not assign subscription';

	/// en: 'Pending payment proofs'
	String get pendingPayments => 'Pending payment proofs';

	/// en: 'No pending payment proofs.'
	String get noPendingPayments => 'No pending payment proofs.';

	/// en: 'Approve'
	String get approve => 'Approve';

	/// en: 'Reject'
	String get reject => 'Reject';

	/// en: 'Admin note'
	String get adminNote => 'Admin note';

	/// en: 'Payment approved'
	String get paymentApproved => 'Payment approved';

	/// en: 'Payment rejected'
	String get paymentRejected => 'Payment rejected';

	/// en: 'Could not review payment'
	String get reviewFailed => 'Could not review payment';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Submitted'
	String get submitted => 'Submitted';

	/// en: 'Payee name'
	String get payeeName => 'Payee name';

	/// en: 'Payment instructions'
	String get instructions => 'Payment instructions';

	/// en: 'Grace days after due date'
	String get defaultGraceDays => 'Grace days after due date';

	/// en: 'Warning days before due'
	String get warningDaysBeforeDue => 'Warning days before due';

	/// en: 'Show payment warnings'
	String get enforceWarnings => 'Show payment warnings';

	/// en: 'Automatically lock after grace ends'
	String get enforceLockout => 'Automatically lock after grace ends';

	/// en: 'Warnings control banners and alerts. Auto-lock only affects the daily job after grace. Manual lock always blocks the app; pay stays available.'
	String get enforcementHint => 'Warnings control banners and alerts. Auto-lock only affects the daily job after grace. Manual lock always blocks the app; pay stays available.';

	/// en: 'QRPH image'
	String get qrphImage => 'QRPH image';

	/// en: 'Upload QRPH'
	String get uploadQrph => 'Upload QRPH';

	/// en: 'Billing settings saved'
	String get billingSaved => 'Billing settings saved';

	/// en: 'Could not save billing settings'
	String get billingSaveFailed => 'Could not save billing settings';

	/// en: 'Pay subscription'
	String get payTitle => 'Pay subscription';

	/// en: 'Scan the QRPH code, send the exact amount, then upload your transaction screenshot.'
	String get paySubtitle => 'Scan the QRPH code, send the exact amount, then upload your transaction screenshot.';

	/// en: 'Upload payment screenshot'
	String get uploadProof => 'Upload payment screenshot';

	/// en: 'Submit for review'
	String get submitProof => 'Submit for review';

	/// en: 'Payment proof submitted'
	String get proofSubmitted => 'Payment proof submitted';

	/// en: 'Could not submit payment proof'
	String get proofSubmitFailed => 'Could not submit payment proof';

	/// en: 'Your payment proof is pending review.'
	String get proofPending => 'Your payment proof is pending review.';

	/// en: 'Your last payment proof was rejected.'
	String get proofRejected => 'Your last payment proof was rejected.';

	/// en: 'This organization has no active subscription.'
	String get noActiveSubscription => 'This organization has no active subscription.';

	/// en: 'Subscription locked'
	String get lockedTitle => 'Subscription locked';

	/// en: 'Access is locked until payment is confirmed. Upload your QRPH transfer screenshot to restore access.'
	String get lockedMessage => 'Access is locked until payment is confirmed. Upload your QRPH transfer screenshot to restore access.';

	/// en: 'Subscription is in grace period. Please pay to avoid losing access.'
	String get graceBanner => 'Subscription is in grace period. Please pay to avoid losing access.';

	/// en: 'Subscription payment is due soon.'
	String get dueSoonBanner => 'Subscription payment is due soon.';

	/// en: 'Subscription due soon'
	String get dueSoonDialogTitle => 'Subscription due soon';

	/// en: '(one) {Your subscription expires in 1 day. Please renew to keep access.} (other) {Your subscription expires in $n days. Please renew to keep access.}'
	String dueSoonDialogMessage({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Your subscription expires in 1 day. Please renew to keep access.',
		other: 'Your subscription expires in ${n} days. Please renew to keep access.',
	);

	/// en: 'Subscription expired'
	String get graceDialogTitle => 'Subscription expired';

	/// en: 'Your subscription is past due. Please pay to avoid losing access.'
	String get graceDialogMessage => 'Your subscription is past due. Please pay to avoid losing access.';

	/// en: 'Later'
	String get remindLater => 'Later';

	/// en: 'Go to payment'
	String get goToPayment => 'Go to payment';

	/// en: 'Organization details'
	String get orgDetails => 'Organization details';

	/// en: 'days'
	String get days => 'days';
}

// Path: validation
class TranslationsValidationEn {
	TranslationsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field is required'
	String get required => 'This field is required';

	/// en: 'Please enter a valid email address'
	String get invalidEmail => 'Please enter a valid email address';

	/// en: 'Please enter a valid phone number'
	String get invalidPhone => 'Please enter a valid phone number';

	/// en: 'Must be at least {min} characters'
	String get minLength => 'Must be at least {min} characters';

	/// en: 'Must be at most {max} characters'
	String get maxLength => 'Must be at most {max} characters';

	/// en: 'Passwords do not match'
	String get passwordMismatch => 'Passwords do not match';

	/// en: 'Please enter a valid number'
	String get invalidNumber => 'Please enter a valid number';

	/// en: 'Please enter a valid date'
	String get invalidDate => 'Please enter a valid date';

	/// en: 'Please enter a valid URL'
	String get invalidUrl => 'Please enter a valid URL';

	/// en: 'Value must be at least {min}'
	String get minValue => 'Value must be at least {min}';

	/// en: 'Value must be at most {max}'
	String get maxValue => 'Value must be at most {max}';

	/// en: 'Please enter a positive number'
	String get positiveNumber => 'Please enter a positive number';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'auth.pageTitle' => 'Login',
			'auth.loginButton' => 'Login',
			'auth.loginAsAdminList.0' => 'Not a user? ',
			'auth.loginAsAdminList.1' => 'Login as Administrator',
			'auth.returnToLoginAsUser.0' => 'Not an administrator? ',
			'auth.returnToLoginAsUser.1' => 'Login as User',
			'auth.loginSuccess' => 'Logged in successfully',
			'auth.logoutButton' => 'Logout',
			'auth.logoutConfirm' => 'Are you sure you want to logout?',
			'auth.forgotPassword' => 'Forgot Password?',
			'auth.forgotPasswordTitle' => 'Forgot Password',
			'auth.forgotPasswordSubtitle' => 'Enter your email address and we\'ll send you a link to reset your password.',
			'auth.sendResetLink' => 'Send Reset Link',
			'auth.backToLogin' => 'Back to Login',
			'auth.checkEmail' => 'Check Your Email',
			'auth.resetLinkSent' => ({required Object email}) => 'Password reset link has been sent to ${email}',
			'auth.signInToContinue' => 'Sign in to continue',
			'auth.continueWithGoogle' => 'Continue with Google',
			'auth.orDivider' => 'or',
			'auth.signingIn' => 'Signing in...',
			'auth.almostThereWarmingUp' => 'You\'re almost there — just warming things up',
			'auth.poweredBy' => 'Powered by HZN Laundry',
			'auth.verificationEmailSent' => 'A verification email has been sent to your email address',
			'auth.continueButton' => 'Continue',
			'auth.changeEmail' => 'Change email',
			'auth.signInWithEmailCode' => 'Sign in with email code',
			'auth.signInWithPassword' => 'Sign in with password',
			'auth.sendLoginCode' => 'Send code',
			'auth.verifyLoginCode' => 'Verify code',
			'auth.enterLoginCode' => 'Login code',
			'auth.loginCodeSent' => ({required Object email}) => 'We sent a login code to ${email}',
			'auth.resendLoginCode' => 'Resend code',
			'auth.resendLoginCodeCooldown' => ({required Object seconds}) => 'Resend in ${seconds}s',
			'auth.loginCodeSendFailed' => 'Could not send login code. Try again later.',
			'auth.scopeRecoveryTitle' => 'Can\'t open your workspace',
			'auth.scopeRecoveryNoMembership' => 'Your account isn\'t assigned to an organization yet. Ask an admin to invite you, then try again.',
			'auth.scopeRecoveryOrgUnavailable' => 'Your organization couldn\'t be loaded. Contact support if this keeps happening.',
			'auth.scopeRecoveryEmptyOrgSlug' => 'Your organization is missing a URL slug, so the app can\'t open the dashboard. Contact support.',
			'auth.scopeRecoveryNoBranch' => 'No branches are available for your organization. Ask an admin to add a branch, then try again.',
			'auth.scopeRecoveryEmptyBranchSlug' => 'Your branch is missing a URL slug, so the app can\'t open the dashboard. Contact support.',
			'auth.scopeRecoveryGeneric' => 'We couldn\'t open your workspace after login. Retry, or sign out and try again.',
			'common.appName' => 'HZN Laundry',
			'common.placeholderText' => 'N/A',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.add' => 'Add',
			'common.close' => 'Close',
			'common.confirm' => 'Confirm',
			'common.submit' => 'Submit',
			'common.search' => 'Search',
			'common.filter' => 'Filter',
			'common.refresh' => 'Refresh',
			'common.loading' => 'Loading...',
			'common.retry' => 'Retry',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.ok' => 'OK',
			'common.done' => 'Done',
			'common.reset' => 'Reset',
			'common.next' => 'Next',
			'common.previous' => 'Previous',
			'common.back' => 'Back',
			'common.viewAll' => 'View All',
			'common.seeMore' => 'See More',
			'common.noResults' => 'No results found',
			'common.emptyList' => 'No items to display',
			'common.discardChanges' => 'Discard changes?',
			'common.discardChangesMessage' => 'You have unsaved changes. Are you sure you want to discard them?',
			'common.discard' => 'Discard',
			'common.keepEditing' => 'Keep Editing',
			'common.sort' => 'Sort',
			'common.fullScreen' => 'Full Screen',
			'common.exitFullScreen' => 'Exit Full Screen',
			'failures.generic' => 'Something went wrong. Please try again.',
			'failures.networkError' => 'Network error. Please check your connection.',
			'failures.serverError' => 'Server error. Please try again later.',
			'failures.unauthorized' => 'You are not authorized to perform this action.',
			'failures.sessionExpired' => 'Your session has expired. Please login again.',
			'failures.notFound' => 'The requested resource was not found.',
			'failures.badRequest' => 'Invalid request. Please check your input.',
			'failures.conflict' => 'A conflict occurred. The resource may already exist.',
			'failures.timeout' => 'Request timed out. Please try again.',
			'failures.noInternet' => 'No internet connection.',
			'failures.invalidCredentials' => 'Invalid email or password.',
			'failures.invalidLoginCode' => 'Invalid or expired login code.',
			'failures.googleNoAccount' => 'No account for this Google email. Ask an admin to create your user first.',
			'failures.otpNoAccount' => 'No account for this email. Ask an admin to create your user first.',
			'failures.googleSignInFailed' => 'Could not start Google sign-in. Please try again.',
			'failures.accountDisabled' => 'Your account has been disabled.',
			'failures.emailNotVerified' => 'Please verify your email address.',
			'failures.tooManyRequests' => 'Too many requests. Please wait a moment.',
			'fields.email' => 'Email',
			'fields.password' => 'Password',
			'fields.passwordConfirmation' => 'Password confirmation',
			'fields.name' => 'Name',
			'fields.contactNumber' => 'Contact Number',
			'fields.address' => 'Address',
			'fields.searchFields' => 'Search Fields',
			'fields.searchFieldsHint' => 'Select which fields to include in your search',
			'fields.requiredField' => 'Required',
			'fields.atLeastOneRequired' => 'At least one field required',
			'fields.receiptNumber' => 'Receipt Number',
			'fields.customerName' => 'Customer Name',
			'fields.paymentRef' => 'Payment Reference',
			'fields.notes' => 'Notes',
			'fields.description' => 'Description',
			'fields.category' => 'Category',
			'fields.paymentFilters' => 'Payment Filters',
			'fields.paid' => 'Paid',
			'fields.unpaid' => 'Unpaid',
			'fields.cash' => 'Cash',
			'fields.gcashBank' => 'GCash/Bank',
			'navigation.shortcuts' => 'Shortcuts',
			'navigation.categories' => 'Categories',
			'navigation.showMore' => 'Show more',
			'navigation.showLess' => 'Show less',
			'navigation.operations' => 'Operations',
			'navigation.people' => 'People',
			'navigation.insights' => 'Insights',
			'navigation.administration' => 'Administration',
			'navigation.collapseNav' => 'Collapse navigation',
			'navigation.expandNav' => 'Expand navigation',
			'navigation.dashboard' => 'Dashboard',
			'navigation.products' => 'Products',
			'navigation.inventory' => 'Inventory',
			'navigation.settings' => 'Settings',
			'navigation.profile' => 'Profile',
			'navigation.reports' => 'Reports',
			'navigation.users' => 'Users',
			'navigation.roles' => 'Roles',
			'navigation.branches' => 'Branches',
			'navigation.more' => 'More',
			'navigation.sales' => 'Cashier',
			'navigation.salesHistory' => 'Orders',
			'navigation.management' => 'Management',
			'navigation.organizations' => 'Organizations',
			'navigation.services' => 'Services',
			'navigation.customers' => 'Customers',
			'navigation.employees' => 'Employees',
			'navigation.system' => 'System',
			'navigation.account' => 'Account',
			'navigation.noBranch' => 'No Branch',
			'navigation.allBranches' => 'All Branches',
			'navigation.switchingBranch' => 'Switching branch…',
			'navigation.switchingToBranch' => ({required Object name}) => 'Switching to ${name}…',
			'navigation.posUnavailableAllBranches' => 'Cashier is not available when All Branches is selected. Choose a specific branch to continue.',
			'navigation.createUnavailableAllBranches' => 'This action requires a specific branch. Choose a branch before continuing.',
			'navigation.activities' => 'Activities',
			'navigation.searchNavHint' => 'Search pages',
			'navigation.searchResults' => 'Search results',
			'navigation.noSearchResults' => 'No results',
			'organizations.title' => 'Organizations',
			'organizations.create' => 'Create Organization',
			'organizations.yourOrganizations' => 'Organizations you\'re in',
			'organizations.yourRole' => 'Your role',
			'organizations.switchToThis' => 'Switch to this organization',
			'organizations.current' => 'Current',
			'organizations.details' => 'Details',
			'organizations.saveDetails' => 'Save details',
			'organizations.invitePeople' => 'Invite people',
			'organizations.inviteEmail' => 'Email',
			'organizations.inviteRole' => 'Role',
			'organizations.sendInvite' => 'Send invite',
			'organizations.pendingInvites' => 'Pending invites for you',
			'organizations.pendingOrgInvites' => 'Pending invites',
			'organizations.accept' => 'Accept',
			'organizations.decline' => 'Decline',
			'organizations.revoke' => 'Revoke',
			'organizations.noOrganizations' => 'You don\'t belong to any organizations yet.',
			'organizations.contactAdmin' => 'Contact your administrator to be invited to an organization.',
			'organizations.inviteSent' => 'Invite sent',
			'organizations.inviteAccepted' => 'Invite accepted',
			'organizations.inviteDeclined' => 'Invite declined',
			'organizations.inviteRevoked' => 'Invite revoked',
			'organizations.saveSuccess' => 'Organization updated',
			'organizations.switchOrganization' => 'Organization',
			'organizations.switchingOrganization' => 'Switching organization…',
			'organizations.switchingToOrganization' => ({required Object name}) => 'Switching to ${name}…',
			'organizations.setupTitle' => 'Set up your organization',
			'organizations.stepDetails' => 'Organization details',
			'organizations.stepBranch' => 'Create your first branch',
			'organizations.stepSubscription' => 'Choose a subscription',
			'organizations.stepInvite' => 'Invite your team',
			'organizations.stepReview' => 'Review & create',
			'organizations.stepDetailsShort' => 'Details',
			'organizations.stepBranchShort' => 'Branch',
			'organizations.stepSubscriptionShort' => 'Plan',
			'organizations.stepInviteShort' => 'Team',
			'organizations.stepReviewShort' => 'Review',
			'organizations.subscriptionRequired' => 'Select a subscription package to continue.',
			'organizations.next' => 'Next',
			'organizations.back' => 'Back',
			'organizations.skip' => 'Skip',
			'organizations.finish' => 'Create organization',
			'organizations.addBranch' => 'Add branch',
			'organizations.branchRequired' => 'Enter the first branch details to continue.',
			'organizations.noBranchYet' => 'No branch yet',
			'organizations.onboardingComplete' => 'Organization is ready',
			'organizations.operatingHours' => 'Operating Hours',
			'organizations.cutOffTime' => 'Cut-off Time',
			'organizations.addInvite' => 'Add invite',
			'organizations.noInvitesQueued' => 'No invites queued. You can skip this step.',
			'organizations.queuedInvites' => 'Queued invites',
			'organizations.inviteQueued' => 'Invite added',
			'organizations.inviteAlreadyQueued' => 'That email is already queued.',
			'organizations.removeInvite' => 'Remove',
			'organizations.reviewInviteCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 queued invite', other: '${n} queued invites', ), 
			'organizations.reviewNone' => '—',
			'organizations.overviewTab' => 'Overview',
			'organizations.peopleTab' => 'People',
			'organizations.featuresTab' => 'Features',
			'organizations.members' => 'Members',
			'organizations.noMembers' => 'No members found.',
			'organizations.featuresModules' => 'Modules',
			'organizations.featuresNotifications' => 'Notifications',
			'organizations.featuresWorkflow' => 'Order workflow',
			'organizations.consumableUsage' => 'Consumable usage',
			'organizations.sendHistoryEmails' => 'Send order history emails',
			'organizations.requireMachine' => 'Require machine assignment',
			'organizations.requirePack' => 'Require pack count',
			'organizations.requireStorage' => 'Require storage assignment',
			'organizations.featuresReadOnly' => 'Only organization managers can change these features.',
			'organizations.selectTitle' => 'Select organization',
			'organizations.selectSubtitle' => 'Choose which organization you want to work in.',
			'organizations.lastUsed' => 'Last used',
			'organizations.expiringInDays' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Expiring in 1 day', other: 'Expiring in ${n} days', ), 
			'organizations.subscriptionExpired' => 'Expired',
			'organizations.subscriptionLocked' => 'Locked',
			'organizations.superAdmin' => 'Super Admin',
			'organizations.superAdminTitle' => 'Super Admin',
			'organizations.superAdminSubtitle' => 'Platform overview across all organizations.',
			'organizations.platformOverview' => 'Platform overview',
			'organizations.allOrganizations' => 'All organizations',
			'organizations.searchOrganizations' => 'Search organizations',
			'organizations.noOrganizationsYet' => 'No organizations yet.',
			'organizations.noMatchingOrganizations' => 'No organizations match your search.',
			'organizations.kpiOrganizations' => 'Organizations',
			'organizations.kpiOrders' => 'Orders',
			'organizations.kpiCustomers' => 'Customers',
			'organizations.kpiRevenue' => 'Revenue',
			'organizations.metricBranches' => 'Branches',
			'organizations.metricMembers' => 'Members',
			'organizations.metricOrders' => 'Orders',
			'organizations.metricCustomers' => 'Customers',
			'organizations.onboarded' => 'Onboarded',
			'organizations.notOnboarded' => 'Not onboarded',
			'organizations.statsLoadError' => 'Could not load organization stats.',
			'sort.sortBy' => 'Sort By',
			'sort.direction' => 'Direction',
			'sort.ascending' => 'Ascending',
			'sort.descending' => 'Descending',
			'sort.dateAdded' => 'Date Added',
			'sort.lastUpdated' => 'Last Updated',
			'sort.date' => 'Date',
			'sort.amount' => 'Amount',
			'sort.price' => 'Price',
			'sort.stock' => 'Stock',
			'sort.expiration' => 'Expiration',
			'sort.status' => 'Status',
			'subscriptions.tabOverview' => 'Dashboard',
			'subscriptions.tabPackages' => 'Packages',
			'subscriptions.tabPayments' => 'Payments',
			'subscriptions.tabBilling' => 'Billing',
			'subscriptions.subscription' => 'Subscription',
			'subscriptions.noSubscription' => 'No subscription',
			'subscriptions.statusActive' => 'Active',
			'subscriptions.statusGrace' => 'Grace',
			'subscriptions.statusLocked' => 'Locked',
			'subscriptions.statusCancelled' => 'Cancelled',
			'subscriptions.periodEnds' => 'Period ends',
			'subscriptions.periodStart' => 'Period start',
			'subscriptions.periodEnd' => 'Period end',
			'subscriptions.periodDatesHint' => 'Leave blank to use today + package interval',
			'subscriptions.periodStartRequiredWithEnd' => 'Start date is required when end date is set',
			'subscriptions.periodEndAfterStart' => 'End date must be after start date',
			'subscriptions.graceEnds' => 'Grace ends',
			'subscriptions.pendingProofs' => 'Pending proofs',
			'subscriptions.assignPackage' => 'Assign package',
			'subscriptions.changePackage' => 'Change package',
			'subscriptions.manualUnlock' => 'Manual unlock',
			'subscriptions.manualLock' => 'Lock organization',
			'subscriptions.unlockUntil' => 'Unlock until',
			'subscriptions.unlockSuccess' => 'Organization unlocked',
			'subscriptions.unlockFailed' => 'Could not unlock organization',
			'subscriptions.lockSuccess' => 'Organization locked',
			'subscriptions.lockFailed' => 'Could not lock organization',
			'subscriptions.lockConfirmMessage' => 'The organization will be unusable until unlocked or payment is approved. Users can still open the pay screen.',
			'subscriptions.packageName' => 'Package name',
			'subscriptions.packageDescription' => 'Description',
			'subscriptions.packagePrice' => 'Price (₱)',
			'subscriptions.intervalCount' => 'Every',
			'subscriptions.intervalUnit' => 'Interval',
			'subscriptions.intervalDay' => 'Day(s)',
			'subscriptions.intervalMonth' => 'Month(s)',
			'subscriptions.intervalYear' => 'Year(s)',
			'subscriptions.isPremade' => 'Premade package',
			'subscriptions.createPackage' => 'Create package',
			'subscriptions.editPackage' => 'Edit package',
			'subscriptions.deletePackage' => 'Delete package',
			'subscriptions.packageCreated' => 'Package created',
			'subscriptions.packageUpdated' => 'Package updated',
			'subscriptions.packageDeleted' => 'Package deleted',
			'subscriptions.noPackages' => 'No packages yet.',
			'subscriptions.selectPackage' => 'Select a package',
			'subscriptions.customPackage' => 'Custom package',
			'subscriptions.assignSuccess' => 'Subscription assigned',
			'subscriptions.assignFailed' => 'Could not assign subscription',
			'subscriptions.pendingPayments' => 'Pending payment proofs',
			'subscriptions.noPendingPayments' => 'No pending payment proofs.',
			'subscriptions.approve' => 'Approve',
			'subscriptions.reject' => 'Reject',
			'subscriptions.adminNote' => 'Admin note',
			'subscriptions.paymentApproved' => 'Payment approved',
			'subscriptions.paymentRejected' => 'Payment rejected',
			'subscriptions.reviewFailed' => 'Could not review payment',
			'subscriptions.amount' => 'Amount',
			'subscriptions.submitted' => 'Submitted',
			'subscriptions.payeeName' => 'Payee name',
			'subscriptions.instructions' => 'Payment instructions',
			'subscriptions.defaultGraceDays' => 'Grace days after due date',
			'subscriptions.warningDaysBeforeDue' => 'Warning days before due',
			'subscriptions.enforceWarnings' => 'Show payment warnings',
			'subscriptions.enforceLockout' => 'Automatically lock after grace ends',
			'subscriptions.enforcementHint' => 'Warnings control banners and alerts. Auto-lock only affects the daily job after grace. Manual lock always blocks the app; pay stays available.',
			'subscriptions.qrphImage' => 'QRPH image',
			'subscriptions.uploadQrph' => 'Upload QRPH',
			'subscriptions.billingSaved' => 'Billing settings saved',
			'subscriptions.billingSaveFailed' => 'Could not save billing settings',
			'subscriptions.payTitle' => 'Pay subscription',
			'subscriptions.paySubtitle' => 'Scan the QRPH code, send the exact amount, then upload your transaction screenshot.',
			'subscriptions.uploadProof' => 'Upload payment screenshot',
			'subscriptions.submitProof' => 'Submit for review',
			'subscriptions.proofSubmitted' => 'Payment proof submitted',
			'subscriptions.proofSubmitFailed' => 'Could not submit payment proof',
			'subscriptions.proofPending' => 'Your payment proof is pending review.',
			'subscriptions.proofRejected' => 'Your last payment proof was rejected.',
			'subscriptions.noActiveSubscription' => 'This organization has no active subscription.',
			'subscriptions.lockedTitle' => 'Subscription locked',
			'subscriptions.lockedMessage' => 'Access is locked until payment is confirmed. Upload your QRPH transfer screenshot to restore access.',
			'subscriptions.graceBanner' => 'Subscription is in grace period. Please pay to avoid losing access.',
			'subscriptions.dueSoonBanner' => 'Subscription payment is due soon.',
			'subscriptions.dueSoonDialogTitle' => 'Subscription due soon',
			'subscriptions.dueSoonDialogMessage' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Your subscription expires in 1 day. Please renew to keep access.', other: 'Your subscription expires in ${n} days. Please renew to keep access.', ), 
			'subscriptions.graceDialogTitle' => 'Subscription expired',
			'subscriptions.graceDialogMessage' => 'Your subscription is past due. Please pay to avoid losing access.',
			'subscriptions.remindLater' => 'Later',
			'subscriptions.goToPayment' => 'Go to payment',
			'subscriptions.orgDetails' => 'Organization details',
			'subscriptions.days' => 'days',
			'validation.required' => 'This field is required',
			'validation.invalidEmail' => 'Please enter a valid email address',
			'validation.invalidPhone' => 'Please enter a valid phone number',
			'validation.minLength' => 'Must be at least {min} characters',
			'validation.maxLength' => 'Must be at most {max} characters',
			'validation.passwordMismatch' => 'Passwords do not match',
			'validation.invalidNumber' => 'Please enter a valid number',
			'validation.invalidDate' => 'Please enter a valid date',
			'validation.invalidUrl' => 'Please enter a valid URL',
			'validation.minValue' => 'Value must be at least {min}',
			'validation.maxValue' => 'Value must be at most {max}',
			'validation.positiveNumber' => 'Please enter a positive number',
			_ => null,
		};
	}
}
