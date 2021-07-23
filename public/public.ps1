# Public classes, enums and variables

Enum listDocs {
    SeperateFiles = 0
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