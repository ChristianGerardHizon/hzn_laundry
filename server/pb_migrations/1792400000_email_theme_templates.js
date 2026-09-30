/// <reference path="../pb_data/types.d.ts" />
//
// Restyles the PocketBase-managed `users` email templates (password reset,
// email verification, email change) to match the sign-in OTP template:
// dark header, teal accent bar, white card, teal button, signature footer.
//
// The layout is inlined on purpose so the migration is self-contained. Keep
// it visually in sync with server/pb_hooks/lib/email_layout.js.

// Named uniquely (and constants kept local) because migration files may share
// one JS global scope.
function themedEmail_1792400000(opts) {
  const ACCENT = "#45A9AB"
  const INK = "#0B0B0B"
  const FONT = "Arial,Helvetica,sans-serif"

  const p = (text, size, color, mb) =>
    `<p style="margin:0 0 ${mb}px;font-family:${FONT};font-size:${size}px;color:${color};line-height:1.6;">${text}</p>`

  let body = `<h1 style="margin:0 0 12px;font-family:${FONT};font-size:20px;font-weight:bold;color:#111827;line-height:1.35;">${opts.title}</h1>`
  body += p(opts.intro, 15, "#4B5563", 20)
  body +=
    `<table role="presentation" cellspacing="0" cellpadding="0" border="0" style="border-collapse:collapse;margin:0 0 20px;">` +
    `<tr><td align="center" bgcolor="${ACCENT}" style="background-color:${ACCENT};border-radius:8px;">` +
    `<a href="${opts.url}" target="_blank" style="display:inline-block;padding:14px 28px;font-family:${FONT};font-size:15px;font-weight:bold;color:${INK};text-decoration:none;border-radius:8px;">${opts.button}</a>` +
    `</td></tr></table>`
  body +=
    `<p style="margin:0 0 4px;font-family:${FONT};font-size:12px;color:#6B7280;line-height:1.5;">Button not working? Paste this link into your browser:</p>` +
    `<p style="margin:0 0 20px;font-family:${FONT};font-size:12px;line-height:1.5;word-break:break-all;"><a href="${opts.url}" style="color:#2F7A7C;text-decoration:underline;">${opts.url}</a></p>`
  body += p(opts.note, 14, "#6B7280", 0)

  return (
    `<!DOCTYPE html>\r\n` +
    `<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">\r\n` +
    `<head>\r\n` +
    `  <meta charset="utf-8">\r\n` +
    `  <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n` +
    `  <meta http-equiv="X-UA-Compatible" content="IE=edge">\r\n` +
    `  <meta name="x-apple-disable-message-reformatting">\r\n` +
    `  <meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no">\r\n` +
    `  <title>${opts.title}</title>\r\n` +
    `</head>\r\n` +
    `<body style="margin:0;padding:0;background-color:#F4F5F7;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;">\r\n` +
    `  <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">${opts.preheader}</div>\r\n` +
    `  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#F4F5F7;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;">\r\n` +
    `    <tr><td align="center" style="padding:32px 16px;">\r\n` +
    `      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:600px;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;">\r\n` +
    `        <tr><td style="background-color:${INK};padding:20px 28px;border-radius:8px 8px 0 0;">\r\n` +
    `          <p style="margin:0;font-family:${FONT};font-size:16px;font-weight:bold;color:#FFFFFF;line-height:1.3;">{APP_NAME}</p>\r\n` +
    `          <p style="margin:2px 0 0;font-family:${FONT};font-size:12px;color:${ACCENT};line-height:1.3;">HZN systems</p>\r\n` +
    `        </td></tr>\r\n` +
    `        <tr><td style="height:3px;line-height:3px;font-size:3px;background-color:${ACCENT};">&nbsp;</td></tr>\r\n` +
    `        <tr><td style="background-color:#FFFFFF;padding:32px 28px;border-left:1px solid #E5E7EB;border-right:1px solid #E5E7EB;">\r\n` +
    body +
    `\r\n        </td></tr>\r\n` +
    `        <tr><td style="background-color:#FFFFFF;padding:20px 28px 28px;border:1px solid #E5E7EB;border-top:0;border-radius:0 0 8px 8px;">\r\n` +
    `          <p style="margin:0 0 8px;font-family:${FONT};font-size:13px;color:#6B7280;line-height:1.5;">Kind regards,<br>The {APP_NAME} team</p>\r\n` +
    `          <p style="margin:16px 0 0;padding-top:16px;border-top:1px solid #F3F4F6;font-family:${FONT};font-size:11px;color:#9CA3AF;line-height:1.5;">This is an automated transactional message from HZN systems regarding your {APP_NAME} account. Please do not reply to this email.</p>\r\n` +
    `        </td></tr>\r\n` +
    `      </table>\r\n` +
    `    </td></tr>\r\n` +
    `  </table>\r\n` +
    `</body>\r\n</html>`
  )
}

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "resetPasswordTemplate": {
      "subject": "Reset your {APP_NAME} password",
      "body": themedEmail_1792400000({
        title: "Reset your password",
        preheader: "Use the link to choose a new {APP_NAME} password.",
        intro: "We received a request to reset the password for your {APP_NAME} account. Use the button below to choose a new one.",
        button: "Reset password",
        url: "{APP_URL}/reset-password.html?token={TOKEN}",
        note: "If you did not ask to reset your password, you can safely ignore this message. Your account remains secure.",
      }),
    },
    "verificationTemplate": {
      "subject": "Welcome to {APP_NAME}! Please confirm your email",
      "body": themedEmail_1792400000({
        title: "Verify your email address",
        preheader: "Confirm your email to finish setting up {APP_NAME}.",
        intro: "Thank you for joining {APP_NAME}. Confirm your email address with the button below to finish setting up your account.",
        button: "Verify email",
        url: "{APP_URL}/_/#/auth/confirm-verification/{TOKEN}",
        note: "If you did not create this account, you can safely ignore this message.",
      }),
    },
    "confirmEmailChangeTemplate": {
      "subject": "Confirm your {APP_NAME} new email address",
      "body": themedEmail_1792400000({
        title: "Confirm your new email address",
        preheader: "Confirm the new email address for your {APP_NAME} account.",
        intro: "Use the button below to confirm the new email address for your {APP_NAME} account.",
        button: "Confirm new email",
        url: "{APP_URL}/_/#/auth/confirm-email-change/{TOKEN}",
        note: "If you did not ask to change your email address, you can safely ignore this message.",
      }),
    },
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  unmarshal({
    "resetPasswordTemplate": {
      "body": "<p>Hello,</p>\n<p>Click on the button below to reset your password.</p>\n<p>\n  <a class=\"btn\" href=\"{APP_URL}/reset-password.html?token={TOKEN}\" target=\"_blank\" rel=\"noopener\">Reset password</a>\n</p>\n<p><i>If you didn't ask to reset your password, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>",
      "subject": "Reset your {APP_NAME} password"
    },
    "verificationTemplate": {
      "body": "<!DOCTYPE html>\n<html>\n<head>\n  <meta charset=\"UTF-8\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n  <title>Verify Your Email</title>\n  <style>\n    body {\n      font-family: Arial, sans-serif;\n      background-color: #f4f4f4;\n      color: #333;\n      margin: 0;\n      padding: 20px;\n    }\n    .container {\n      background-color: #ffffff;\n      padding: 20px;\n      max-width: 600px;\n      margin: auto;\n      border-radius: 8px;\n      box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);\n    }\n    .btn {\n      display: inline-block;\n      background-color: #007bff;\n      color: #ffffff;\n      padding: 12px 20px;\n      text-decoration: none;\n      font-weight: bold;\n      border-radius: 5px;\n    }\n    .footer {\n      font-size: 12px;\n      color: #777;\n      margin-top: 20px;\n    }\n  </style>\n</head>\n<body>\n\n  <div class=\"container\">\n    <h2>Hello,</h2>\n    <p>Thank you for signing up with <strong>{APP_NAME}</strong>!</p>\n    <p>To complete your registration, please verify your email address by clicking the button below:</p>\n\n    <p style=\"text-align: center;\">\n      <a class=\"btn\" href=\"{APP_URL}/_/#/auth/confirm-verification/{TOKEN}\" target=\"_blank\" rel=\"noopener\">Verify Email</a>\n    </p>\n\n    <p>If the button above does not work, you can also copy and paste the following link into your browser:</p>\n    <p><a href=\"{APP_URL}/_/#/auth/confirm-verification/{TOKEN}\">{APP_URL}/_/#/auth/confirm-verification/{TOKEN}</a></p>\n\n    <p>Thank you,</p>\n    <p>The {APP_NAME} Team</p>\n\n    <div class=\"footer\">\n      <p>If you did not sign up for {APP_NAME}, please ignore this email.</p>\n      <p>&copy; 2025 {APP_NAME}. All rights reserved.</p>\n    </div>\n  </div>\n\n</body>\n</html>\n",
      "subject": "Welcome to {APP_NAME}! Please confirm your email"
    },
    "confirmEmailChangeTemplate": {
      "body": "<p>Hello,</p>\n<p>Click on the button below to confirm your new email address.</p>\n<p>\n  <a class=\"btn\" href=\"{APP_URL}/_/#/auth/confirm-email-change/{TOKEN}\" target=\"_blank\" rel=\"noopener\">Confirm new email</a>\n</p>\n<p><i>If you didn't ask to change your email address, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>",
      "subject": "Confirm your {APP_NAME} new email address"
    }
  }, collection)

  return app.save(collection)
})
