# انتشار قابل‌به‌روزرسانی اندروید گل‌پول

ساخت Release مستقل از ساخت Debug است؛ فرایند `.github/workflows/android-release.yml` با هر Push به `main` اجرا می‌شود.

## تنظیم یک‌باره چهار GitHub Actions Secret

فایل خصوصی `golpool_release_signing_PRIVATE.zip` را از همین گفتگو دانلود و **خارج از مخزن GitHub** نگهداری کنید. در فایل `github_secrets.txt` مقدار کامل هر مورد موجود است.

در GitHub به `Settings > Secrets and variables > Actions > New repository secret` بروید و این نام‌ها را با مقدار متناظر وارد کنید:

- `GOLPOOL_KEYSTORE_BASE64`
- `GOLPOOL_KEYSTORE_PASSWORD`
- `GOLPOOL_KEY_PASSWORD`
- `GOLPOOL_KEY_ALIAS`

**هیچ‌کدام را در فایل‌های مخزن، Issues، پیام عمومی یا تصویر منتشر نکنید.**

## سازگاری به‌روزرسانی

- Android applicationId ثابت: `ir.golpool.finance`.
- همان کلید خصوصی برای همه نسخه‌ها لازم است؛ فقدان کلید به‌معنای عدم امکان به‌روزرسانی مستقیم است.
- شماره ساخت `versionCode` از GitHub Actions run_number می‌آید و با هر اجرای Workflow افزایش می‌یابد.
- برای نصب نسخه بعدی، APK جدید روی نسخه Release قبلی نصب می‌شود، بدون حذف قبلی؛ به شرط ثبات امضا، شناسه و افزایش versionCode.
- **نسخه Debug قبلی** با امضای دیگری ساخته شده است؛ اولین Release ممکن است به حذف نسخه Debug نیاز داشته باشد.
- APK روی اندروید **خودکار نصب یا خودکار به‌روزرسانی نمی‌شود**؛ کاربر باید فایل تازه را نصب کند یا در آینده سامانه امن بروزرسانی داخل اپ/فروشگاه اضافه شود.
- تا زمانی که آزمون نصب و مهاجرت داده روی دستگاه واقعی انجام نشود، حفظ اطلاعات را تضمین نمی‌کنیم.

اگر Secretها ثبت نشده باشند، گردش‌کار عمداً قبل از امضای APK متوقف می‌شود؛ Release بدون امضای انتشار ارائه نخواهد شد.
