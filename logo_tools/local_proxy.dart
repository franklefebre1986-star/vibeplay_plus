<?php
/**
 * 🔥 Generate a JSON file with all available logo paths.
 * Usage (in terminal):
 * php generate-logos-json.php
 */

error_reporting(E_ALL);
if (PHP_SAPI !== 'cli') {
    die("❌ Run this script via command line (not from a browser).");
}

// 🔧 SETTINGS
$settings = [
    'searchDirs' => [
        __DIR__ . '/../assets/logos', // jouw lokale map met PNG's
    ],
    'outputFile' => __DIR__ . '/../assets/logos.json',
    'extensions' => '/\.(png|jpg|jpeg|svg)$/i',
];

// 🧭 Functie: alle bestanden in map vinden
function listAllFiles($dir, $pattern)
{
    $result = [];
    $items = scandir($dir);
    foreach ($items as $item) {
        if ($item === '.' || $item === '..') continue;
        $path = $dir . DIRECTORY_SEPARATOR . $item;
        if (is_dir($path)) {
            $result = array_merge($result, listAllFiles($path, $pattern));
        } elseif (preg_match($pattern, $item)) {
            $result[] = $path;
        }
    }
    return $result;
}

// 🧩 Functie: slugify bestandsnaam
function slugify($name)
{
    $name = strtolower($name);
    $name = preg_replace('/[^a-z0-9]+/', '-', $name);
    $name = trim($name, '-');
    return $name;
}

// 📦 Hoofdscript
$logos = [];
foreach ($settings['searchDirs'] as $dir) {
    $files = listAllFiles($dir, $settings['extensions']);
    foreach ($files as $file) {
        $filename = basename($file);
        $key = slugify(preg_replace('/\.(png|jpg|jpeg|svg)$/i', '', $filename));
        $relative = str_replace(__DIR__ . '/../', '', $file);
        $logos[$key] = $relative;
    }
}

// 💾 Schrijf naar JSON
$json = json_encode($logos, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
file_put_contents($settings['outputFile'], $json);

echo "✅ Logos JSON file generated successfully:\n";
echo $settings['outputFile'] . "\n";
echo "Total: " . count($logos) . " logos.\n";
