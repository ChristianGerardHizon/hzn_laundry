/// Shared constants for BIR-compliant claim sheet printed output.
///
/// All thermal and PDF claim sheets must use these labels so printed slips
/// are clearly operational documents, not sales invoices or official receipts.

/// Document title for customer/POS copies.
const String claimSheetTitle = 'CLAIM SHEET';

/// Document title for store/machine tag copies.
const String claimSheetStoreCopyTitle = 'CLAIM SHEET - STORE COPY';

/// Reference number label (followed by the receipt/claim sheet number).
const String claimSheetNumberLabel = 'Claim Sheet No:';

/// BIR supplementary-document disclaimer lines (bold, centered on thermal).
const List<String> claimSheetDisclaimerLines = [
  'THIS IS NOT A SALES INVOICE',
  'THIS DOCUMENT IS NOT VALID FOR',
  'CLAIM OF INPUT TAX.',
];
