# Public classes, enums and variables

Enum listDocs {
    SeparateFiles = 0
    CertificateOfCompletion = 4;
    DocumentsCombinedTogether = 5;
    ZIPFile = 6;
}

Class APIVersions {
    static $rooms = "rooms"
    static $eSignature = "eSignature"
    static $click = "click"
    static $monitor = "monitor"
}

Class EnvelopeStatus {
    static $completed = "completed"
    static $created = "created"
    static $declined = 'declined'
    static $deleted = "deleted"
    static $delivered = "delivered"
    static $processing = "processing"
    static $signed = "signed"
    static $timedout = "timedout"
    static $voided = "voided"
}

$contentTypes = @{
 "bmp"  = "image/bmp"
 "csv"  = "text/csv"
 "doc"  = "application/msword"
 "docx" = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
 "htm"  = "text/html"
 "html" = "text/html"
 "json" = "text/json"
 "png"  = "image/png"
 "php"  = "application/x-httpd-php"
 "ppt"  = "application/vnd.ms-powerpoint"
 "pptx" = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
 "vsd"  = "application/vnd.visio"
 "xls"  = "application/vnd.ms-excel"
 "xlsx" = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
}