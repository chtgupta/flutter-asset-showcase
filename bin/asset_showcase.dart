#!/usr/bin/env dart
// Author: Chahat Gupta
// Date: 6 May 2024

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final ArgParser argParser = ArgParser()
    ..addOption('assets',
        defaultsTo: 'assets', help: 'Directory containing assets')
    ..addOption('output',
        defaultsTo: 'showcase.html', help: 'Output HTML file path');

  final ArgResults args = argParser.parse(arguments);

  final String assetsDir = args['assets']!;
  final String outputFilePath = args['output']!;

  generateHtmlForAssets(assetsDir, outputFilePath);
  print(
      'Successfully generated $outputFilePath showcasing assets from $assetsDir');
}

void generateHtmlForAssets(String assetsDir, String outputFilePath) {
  final htmlFile = File(outputFilePath);
  final htmlStream = htmlFile.openWrite();

  // Traverse the assets directory
  final List<String> filePaths = [];
  final Set<String> fileExtensions = {};
  _traverseDirectory(Directory(assetsDir), filePaths, fileExtensions);
  filePaths.sort();

  // Write the HTML header
  htmlStream.write(
      '<!DOCTYPE html>\n<html>\n<head>\n<title>Asset Showcase</title>\n');
  htmlStream.write(
      '<style>html {font-family: monospace;} .grid-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 10px; padding: 10px; } .grid-item { display: flex; flex-direction: column; align-items: center; padding: 10px; } .image { max-width: 100%; max-height: 100%; width: 80px; height: 80px; margin-bottom: 10px; cursor: pointer; transition: transform 0.2s ease-in-out; } .image:hover { transform: scale(1.1); } .file-info { font-size: 12px; margin-top: 10px; } .hidden { display: none; } #search-bar { display: flex; align-items: center; position: sticky; top: 0; background-color: white; z-index: 1; padding: 20px; } #search-input { padding: 8px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px; flex-grow: 1; margin-right: 10px; } .drop { padding: 8px; font-size: 16px; border: 1px solid #ccc; border-radius: 5px; margin-left: 10px; } .file-indicator {width: 80px;height: 80px;background-color: lightgray;display: flex;justify-content: center;align-items: center;font-size: 14px; margin: 5px; cursor: pointer;} .toast-container { position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); z-index: 9999; width: 300px; } .toast { background-color: black; color: white; padding: 10px; margin-bottom: 10px; word-wrap: break-word; }</style>\n');

  htmlStream.write('</head>\n<body>\n');
  htmlStream.write('<div class="toast-container" id="toastContainer"></div>');

  int totalAssets = filePaths.length;
  double totalSize = 0;
  filePaths.forEach((filePath) {
    totalSize += File(filePath).lengthSync() / 1024; // Convert to KB
  });

  String totalSizeText = totalSize < 1024
      ? totalSize.toStringAsFixed(2) + " KB"
      : (totalSize / 1024).toStringAsFixed(2) + " MB";

// Write the search bar and text below it
  htmlStream.write(
      '<div style="display: flex; align-items: center; position: sticky; top: 0; z-index: 1; background-color: white;">');
  htmlStream.write(
      '<div id="search-bar" style="display: flex; align-items: center; flex-grow: 1;">');
  htmlStream.write(
      '<input type="text" id="search-input" placeholder="Search..." style="margin-bottom: 5px;">');
  htmlStream.write('<div class="search-stats" style="margin-left: 10px;">');
  htmlStream.write('Total Assets: $totalAssets | Total Size: $totalSizeText');
  htmlStream.write('</div>');
  htmlStream.write('</div>');

// Write the selectors next to the search bar
  htmlStream.write('<div style="display: flex; align-items: center;">');
  htmlStream.write(
      '<select class="drop" id="sort-select" style="margin-right: 10px;">');
  htmlStream.write('<option value="name_asc">Sort by Name (Asc)</option>');
  htmlStream.write('<option value="name_desc">Sort by Name (Desc)</option>');
  htmlStream.write('<option value="size_asc">Sort by Size (Asc)</option>');
  htmlStream.write('<option value="size_desc">Sort by Size (Desc)</option>');
  htmlStream.write('</select>');
  htmlStream.write(
      '<select id="extension-select-dropdown" class="drop" style="margin-right: 20px;">');
  htmlStream.write('<option value="all">ALL</option>');
  fileExtensions.forEach((element) {
    htmlStream
        .write('<option value="$element">${element.toUpperCase()}</option>');
  });
  htmlStream.write('</select>');
  htmlStream.write('</div>');

  htmlStream
      .write('</div>'); // Close the flex container for search bar and selectors

  htmlStream.write('<div class="grid-container">\n');

  // Write HTML for sorted file paths
  for (final filePath in filePaths) {
    final assetPath = Uri.file(filePath).pathSegments.join('/');
    final fileName = filePath.split('/').last;
    final fileSize = (File(filePath).lengthSync() / 1024)
        .toStringAsFixed(2); // Convert to KB with 2 decimal places
    htmlStream.write('<div class="grid-item" data-file-path="$filePath">\n');

    if (fileName.endsWith('.json')) {
      htmlStream.write('<div class="file-indicator">JSON</div>\n');
    } else if (fileName.endsWith('.svg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.webp')) {
      htmlStream
          .write('<img class="image" src="$assetPath" alt="$fileName">\n');
    } else if (fileName.endsWith('.mp3') || fileName.endsWith('.wav')) {
      // For audio files, include an audio element
      htmlStream.write(
          '<audio controls class="audio" style="width: 200px;"><source src="$assetPath" type="audio/mpeg">Your browser does not support the audio tag.</audio>');
    } else {
      htmlStream.write('<div class="file-indicator">File</div>\n');
    }

    htmlStream.write(
        '<div class="file-info">$fileName ($fileSize KB)<span id="hidden-name" class="hidden">$fileName</span><span id="hidden-size" class="hidden">$fileSize</span></div>\n');
    htmlStream.write('</div>\n');
  }

  // Write the JavaScript for searching and sorting
  htmlStream.write('<script>');
  htmlStream.write(
      'document.getElementById("search-input").addEventListener("input", function() {');
  htmlStream.write('  const searchTerm = this.value.toLowerCase();');
  htmlStream.write('  const images = document.querySelectorAll(".grid-item");');
  htmlStream.write('  images.forEach(function(image) {');
  htmlStream.write(
      '    const fileInfo = image.querySelector(".file-info").textContent.toLowerCase();');
  htmlStream.write('    if (fileInfo.includes(searchTerm)) {');
  htmlStream.write('      image.style.display = "flex";');
  htmlStream.write('    } else {');
  htmlStream.write('      image.style.display = "none";');
  htmlStream.write('    }');
  htmlStream.write('  });');
  htmlStream.write('});');
  htmlStream.write(
      'document.getElementById("sort-select").addEventListener("change", function() {');
  htmlStream.write(
      '  const sortOption = document.getElementById("sort-select").value;');
  htmlStream.write('  sortImages(sortOption);');
  htmlStream.write('});');

  htmlStream.write(
      'document.getElementById("extension-select-dropdown").addEventListener("change", function() {');
  htmlStream.write(
      '  const selectedExtensions = Array.from(this.selectedOptions).map(option => option.value);');
  htmlStream.write('  const images = document.querySelectorAll(".grid-item");');
  htmlStream.write('  images.forEach(function(image) {');
  htmlStream.write(
      '    const fileName = image.querySelector("#hidden-name").textContent;');
  htmlStream.write(
      '    const fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1);');
  htmlStream.write(
      '    if (selectedExtensions.includes(fileExtension) || selectedExtensions.includes("all")) {');
  htmlStream.write('      image.style.display = "flex";');
  htmlStream.write('    } else {');
  htmlStream.write('      image.style.display = "none";');
  htmlStream.write('    }');
  htmlStream.write('  });');
  htmlStream.write('});');

  htmlStream.write('function sortImages(sortOption) {');
  htmlStream.write(
      '  const imagesContainer = document.querySelector(".grid-container");');
  htmlStream.write(
      '  const images = Array.from(imagesContainer.querySelectorAll(".grid-item"));');
  htmlStream.write('  images.sort((a, b) => {');
  htmlStream.write(
      '    const fileInfoA = parseFloat(a.querySelector("#hidden-size").textContent);');
  htmlStream.write(
      '    const fileInfoB = parseFloat(b.querySelector("#hidden-size").textContent);');
  htmlStream.write('    if (sortOption === "name_asc") {');
  htmlStream.write(
      '      const fileNameA = a.querySelector(".file-info").textContent.split(" ")[0];');
  htmlStream.write(
      '      const fileNameB = b.querySelector(".file-info").textContent.split(" ")[0];');
  htmlStream.write('      return fileNameA.localeCompare(fileNameB);');
  htmlStream.write('    } else if (sortOption === "name_desc") {');
  htmlStream.write(
      '      const fileNameA = a.querySelector(".file-info").textContent.split(" ")[0];');
  htmlStream.write(
      '      const fileNameB = b.querySelector(".file-info").textContent.split(" ")[0];');
  htmlStream.write('      return fileNameB.localeCompare(fileNameA);');
  htmlStream.write('    } else if (sortOption === "size_asc") {');
  htmlStream.write('      return fileInfoA - fileInfoB;');
  htmlStream.write('    } else if (sortOption === "size_desc") {');
  htmlStream.write('      return fileInfoB - fileInfoA;');
  htmlStream.write('    }');
  htmlStream.write('  });');
  htmlStream
      .write('  images.forEach(image => imagesContainer.appendChild(image));');

  htmlStream.write('}');

// Write the code for attaching event listeners
  htmlStream.write('function attachEventListeners() {');
  htmlStream.write('  function copyFilePath(filePath) {');
  htmlStream.write('    const el = document.createElement("textarea");');
  htmlStream.write('    el.value = filePath;');
  htmlStream.write('    document.body.appendChild(el);');
  htmlStream.write('    el.select();');
  htmlStream.write('    document.execCommand("copy");');
  htmlStream.write('    document.body.removeChild(el);');
  htmlStream.write('    showToast("Asset path copied");');
  htmlStream.write('  }');

  htmlStream.write('  const images = document.querySelectorAll(".image");');
  htmlStream.write('  images.forEach(image => {');
  htmlStream.write('    image.addEventListener("click", () => {');
  htmlStream.write(
      '      const filePath = image.parentElement.getAttribute("data-file-path");');
  htmlStream.write('      copyFilePath(filePath);');
  htmlStream.write('    });');
  htmlStream.write('  });');

  htmlStream
      .write('  const audioElements = document.querySelectorAll("audio");');
  htmlStream.write('  audioElements.forEach(audio => {');
  htmlStream.write('    audio.addEventListener("play", () => {');
  htmlStream.write('      pauseOtherAudios(audio);');
  htmlStream.write('    });');
  htmlStream.write('  });');

  htmlStream
      .write('  const fileInfos = document.querySelectorAll(".file-info");');
  htmlStream.write('  fileInfos.forEach(fileInfo => {');
  htmlStream.write('    fileInfo.addEventListener("click", () => {');
  htmlStream.write(
      '      const filePath = fileInfo.parentElement.getAttribute("data-file-path");');
  htmlStream.write('      copyFilePath(filePath);');
  htmlStream.write('    });');
  htmlStream.write('  });');
  htmlStream.write('}');

  htmlStream.write('function pauseOtherAudios(currentAudio) {');
  htmlStream
      .write('  const audioElements = document.querySelectorAll("audio");');
  htmlStream.write('  audioElements.forEach(audio => {');
  htmlStream.write('    if (audio !== currentAudio) {');
  htmlStream.write('      audio.pause();');
  htmlStream.write('    }');
  htmlStream.write('  });');
  htmlStream.write('}');

  htmlStream.write('attachEventListeners();');

  htmlStream.write('function showToast(message) {');
  htmlStream.write(
      '  const toastContainer = document.getElementById("toastContainer");');
  htmlStream.write('  const toast = document.createElement("div");');
  htmlStream.write('  toast.classList.add("toast");');
  htmlStream.write('  toast.textContent = message;');
  htmlStream.write('  toastContainer.appendChild(toast);');
  htmlStream.write('  setTimeout(() => {');
  htmlStream.write('    toastContainer.removeChild(toast);');
  htmlStream.write('  }, 1000);');
  htmlStream.write('}');

  htmlStream.write('</script>');

  // Write the HTML footer
  htmlStream.write('</div>\n</body>\n</html>');

  // Close the file stream
  htmlStream.close();
}

void _traverseDirectory(
    Directory dir, List<String> filePaths, Set<String> fileExtensions) {
  dir.listSync().forEach((entity) {
    if (entity is File) {
      final filePath = entity.path;
      final fileExtension = filePath.split('.').last;
      fileExtensions.add(fileExtension);
      filePaths.add(filePath);
    } else if (entity is Directory) {
      _traverseDirectory(entity, filePaths, fileExtensions);
    }
  });
}
