

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>A simple word counter and tracker</title>
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon"><meta name='robots' content='noindex,follow' /><link rel="icon" href="favicon.ico" type="image/x-icon"><link href="favicon.ico" rel="SHORTCUT ICON"><link rel="stylesheet" type="text/css" href="default.css" /></head>
<body><div id="outer">    
    <div id="menu">
        <ul>
        </ul>
    </div><div id="menubottom"></div><div id="content">    
    <p>Select the file that you wish to have the words counted in and press "submit".  Handles DOC, DOCX, RTF, PDF, markdown, plain text. No data is retained.</p>
    <p>All data input through this form is used ONLY to count the words in the document and (optionally) record the time, submitted name, and word count to <a href="https://faithcollapsing.com/wordcount" target="_blank">a simple record of progress.</a></p>
    <form method="post" action="" enctype="multipart/form-data">
        <label for="username">Put your name here to keep a public record, or leave it as None to be anonymous.</label><br>
        <textarea id="username" name="username" rows="1" cols="50">None</textarea><br>        
        <input type="file" name="file" id="file">
        <input type="submit" value="Upload" name="submit">
    </form>
    <?php


session_start(); // Start PHP session for rate-limiting

// Rate limit configuration
$maxUploads = 3; // Maximum number of uploads
$timeWindow = 6; // Time window in seconds (e.g., 600 = 10 minutes)

// Allowed file extensions and MIME types
$allowedExtensions = ['mkd', 'md', 'doc', 'docx', 'pdf', 'odt', 'txt'];
$allowedMimeTypes = [
    'text/markdown', 
    'text/plain', 
    'application/msword', 
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 
    'application/pdf', 
    'application/vnd.oasis.opendocument.text'
];

// Function to check file validity
function isValidFile($file) {
    global $allowedExtensions, $allowedMimeTypes;

    $fileInfo = pathinfo($file['name']);
    $extension = strtolower($fileInfo['extension']);

    if (!in_array($extension, $allowedExtensions)) {
        return false;
    }

    if (!in_array($file['type'], $allowedMimeTypes)) {
        return false;
    }

    return true;
}


// Rate-limiting function based on IP
function isRateLimited() {
    global $maxUploads, $timeWindow;

    $ipAddress = $_SERVER['REMOTE_ADDR'];

    if (!isset($_SESSION['uploads'])) {
        $_SESSION['uploads'] = [];
    }

    // Remove expired uploads from the session
    $now = time();
    $_SESSION['uploads'] = array_filter($_SESSION['uploads'], function ($upload) use ($now, $timeWindow) {
        return ($now - $upload['time']) < $timeWindow;
    });

    // Count the number of uploads by this IP in the time window
    $ipUploads = array_filter($_SESSION['uploads'], function ($upload) use ($ipAddress) {
        return $upload['ip'] === $ipAddress;
    });

    return count($ipUploads) >= $maxUploads;
}

// Add upload to the session for rate limiting
function logUpload() {
    $ipAddress = $_SERVER['REMOTE_ADDR'];
    $_SESSION['uploads'][] = [
        'ip' => $ipAddress,
        'time' => time()
    ];
}


if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = isset($_POST['username']) ? trim($_POST['username']) : '';

    if (empty($username)) {
        echo "Error: Username is required.";
        exit;
    }
    
    // Check for rate limiting by IP address
    if (isRateLimited()) {
        echo "Error: Rate limit exceeded for your IP address. Please try again later.";
        exit;
    }

    if (!isset($_FILES['file'])) {
        echo "Error: No file uploaded.";
        exit;
    }

    $file = $_FILES['file'];

    // Check if the file is valid
    if (!isValidFile($file)) {
        echo "Error: Invalid file type or extension.";
        exit;
    }
    // Log the upload for rate limiting
    logUpload();
    // Move uploaded file to a temporary directory
    $uploadDir = './uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $filePath = $uploadDir . basename($file['name']);
    if (!move_uploaded_file($file['tmp_name'], $filePath)) {
        echo "Error: Failed to move uploaded file.";
        exit;
    }
    $ipAddress = $_SERVER['REMOTE_ADDR'];
    // Pass file path and username to bash script
    $command = escapeshellcmd("/path/to/file/count_the_words.sh '$filePath' '$username' '$ipAddress' ");
    $output = shell_exec($command);

    // Return output from bash script
    if ($output !== null) {
        echo "<br> Your word count: <br>";
        echo (htmlspecialchars($output));
    } else {
        echo (htmlspecialchars($filePath));
        echo "Error: Failed to execute bash script.";
    }

    // Clean up: Optionally delete the uploaded file
    unlink($filePath);
}
?>
</body>
</html>
