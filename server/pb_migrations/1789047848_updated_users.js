/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "oauth2": {
      "enabled": true
    },
    "otp": {
      "emailTemplate": {
        "body": "<!DOCTYPE html>\r\n<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\">\r\n<head>\r\n  <meta charset=\"utf-8\">\r\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\r\n  <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\r\n  <meta name=\"x-apple-disable-message-reformatting\">\r\n  <meta name=\"format-detection\" content=\"telephone=no,address=no,email=no,date=no,url=no\">\r\n  <title>Your sign-in code</title>\r\n  <!--[if mso]>\r\n  <noscript>\r\n    <xml>\r\n      <o:OfficeDocumentSettings>\r\n        <o:PixelsPerInch>96</o:PixelsPerInch>\r\n      </o:OfficeDocumentSettings>\r\n    </xml>\r\n  </noscript>\r\n  <![endif]-->\r\n</head>\r\n<body style=\"margin:0;padding:0;background-color:#F4F5F7;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;\">\r\n  <div style=\"display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;\">\r\n    Your {APP_NAME} sign-in code is ready. It expires shortly.\r\n  </div>\r\n  <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"background-color:#F4F5F7;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;\">\r\n    <tr>\r\n      <td align=\"center\" style=\"padding:32px 16px;\">\r\n        <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"max-width:600px;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;\">\r\n          <tr>\r\n            <td style=\"background-color:#0B0B0B;padding:20px 28px;border-radius:8px 8px 0 0;\">\r\n              <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"border-collapse:collapse;\">\r\n                <tr>\r\n                  <td width=\"48\" valign=\"middle\" style=\"padding-right:12px;\">\r\n                    <img src=\"{APP_URL}/email/hzn-logo.png\" width=\"40\" height=\"40\" alt=\"HZN systems\" style=\"display:block;border:0;outline:none;text-decoration:none;height:40px;width:40px;\">\r\n                  </td>\r\n                  <td valign=\"middle\">\r\n                    <p style=\"margin:0;font-family:Arial,Helvetica,sans-serif;font-size:16px;font-weight:bold;color:#FFFFFF;line-height:1.3;\">HZN Laundry</p>\r\n                    <p style=\"margin:2px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#02F268;line-height:1.3;\">HZN systems</p>\r\n                  </td>\r\n                </tr>\r\n              </table>\r\n            </td>\r\n          </tr>\r\n          <tr>\r\n            <td style=\"height:3px;line-height:3px;font-size:3px;background-color:#02F268;\">&nbsp;</td>\r\n          </tr>\r\n          <tr>\r\n            <td style=\"background-color:#FFFFFF;padding:32px 28px;border-left:1px solid #E5E7EB;border-right:1px solid #E5E7EB;\">\r\n              <h1 style=\"margin:0 0 12px;font-family:Arial,Helvetica,sans-serif;font-size:20px;font-weight:bold;color:#111827;line-height:1.35;\">Sign-in verification code</h1>\r\n              <p style=\"margin:0 0 20px;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#4B5563;line-height:1.6;\">\r\n                Use the code below to complete signing in to your {APP_NAME} account. For your security, do not share this code with anyone.\r\n              </p>\r\n              <table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"border-collapse:collapse;margin:0 0 20px;\">\r\n                <tr>\r\n                  <td align=\"center\" style=\"background-color:#F9FAFB;border:1px solid #E5E7EB;border-radius:8px;padding:22px 16px;\">\r\n                    <p style=\"margin:0 0 6px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.04em;text-transform:uppercase;color:#6B7280;\">Verification code</p>\r\n                    <p style=\"margin:0;font-family:Consolas,'Courier New',monospace;font-size:32px;letter-spacing:0.35em;font-weight:bold;color:#0B0B0B;line-height:1.2;\">{OTP}</p>\r\n                  </td>\r\n                </tr>\r\n              </table>\r\n              <p style=\"margin:0;font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#6B7280;line-height:1.6;\">\r\n                This code expires soon. If you did not attempt to sign in, you can safely ignore this message. Your account remains secure.\r\n              </p>\r\n            </td>\r\n          </tr>\r\n          <tr>\r\n            <td style=\"background-color:#FFFFFF;padding:20px 28px 28px;border:1px solid #E5E7EB;border-top:0;border-radius:0 0 8px 8px;\">\r\n              <p style=\"margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:13px;color:#6B7280;line-height:1.5;\">\r\n                Kind regards,<br>\r\n                The {APP_NAME} team\r\n              </p>\r\n              <p style=\"margin:16px 0 0;padding-top:16px;border-top:1px solid #F3F4F6;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#9CA3AF;line-height:1.5;\">\r\n                This is an automated transactional message from HZN systems regarding your {APP_NAME} account.\r\n                Please do not reply to this email.\r\n              </p>\r\n            </td>\r\n          </tr>\r\n        </table>\r\n      </td>\r\n    </tr>\r\n  </table>\r\n</body>\r\n</html>",
        "subject": "Your {APP_NAME} sign-in code"
      },
      "enabled": true,
      "length": 6
    }
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "oauth2": {
      "enabled": false
    },
    "otp": {
      "emailTemplate": {
        "body": "<p>Hello,</p>\n<p>Your one-time password is: <strong>{OTP}</strong></p>\n<p><i>If you didn't ask for the one-time password, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>",
        "subject": "OTP for {APP_NAME}"
      },
      "enabled": false,
      "length": 8
    }
  }, collection)

  return app.save(collection)
})
