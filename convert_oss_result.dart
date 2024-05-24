// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final envVars = Platform.environment;

  final fileLocaltion =
      '${envVars['HOME']}/.ort/ort-results/advisor-result.json';
  final file = File(fileLocaltion);

  print('Looking for advisor results in $fileLocaltion \n');

  if (!file.existsSync()) {
    print('Advisor result not found on disk');
    exit(2);
  }

  final content = file.readAsStringSync();
  final jsonContent = jsonDecode(content);

  final advisorContent = jsonContent['advisor'];

  if (advisorContent == null) {
    onInvalidInput('Expected root json key "advisor"');
  }

  final resultsContent = advisorContent['results'];

  if (resultsContent == null) {
    onInvalidInput('Expected "results" key in "advisor"');
  }

  final advisorResults = resultsContent['advisor_results'];

  if (advisorResults == null) {
    onInvalidInput('Expected "advisor_results" key in "results"');
  }

  if (advisorResults is! Map) {
    onInvalidInput('Expected "advisor_results" to be a map');
  }

  final advisorResultsMap = Map<String, dynamic>.from(
    advisorResults,
  );

  final extractedVulnerabilities = extractVulnerabilities(advisorResultsMap);

  final outputFile = File('vulneravilities.json');

  if (outputFile.existsSync()) {
    print('vulneravilities.json already exists');
    exit(17);
  }

  outputFile.createSync();
  outputFile.writeAsStringSync(jsonEncode(extractedVulnerabilities));

  logOutput(extractedVulnerabilities);
}

List<Map<String, dynamic>> extractVulnerabilities(
  Map<String, dynamic> advisorResultsMap,
) {
  final List<Map<String, dynamic>> extractedVulnerabilities = [];

  for (var entry in advisorResultsMap.entries) {
    String packageName;
    String packageManager;

    if (entry.key.contains('::')) {
      packageManager = entry.key.split('::').first;
      packageName = entry.key.split('::')[1];
    } else {
      packageName = entry.key;
      packageManager = 'UNKNOWN';
    }
    // final packageManager
    final packageResults = entry.value;

    if (packageResults is! List) {
      onInvalidInput('Expected "advisor_results" to be a map of Lists');
    }

    for (var packageResult in packageResults) {
      if (packageResult is! Map) {
        onInvalidInput('Expected each package result to be a map');
      }

      if (packageResult['vulnerabilities'] != null) {
        // Package contains vulnerabilities
        final vulnerabilities = List<Map<String, dynamic>>.from(
          packageResult['vulnerabilities'],
        );

        for (var vulnerability in vulnerabilities) {
          vulnerability['package_name'] = packageName;
          vulnerability['package_manager'] = packageManager;

          extractedVulnerabilities.add(vulnerability);
        }
      }
    }
  }

  return extractedVulnerabilities;
}

void logOutput(List<Map<String, dynamic>> res) {
  final name = res.length == 1 ? 'vulnerability' : 'vulnerabilities';
  print('Found ${res.length} $name \n');

  for (var vul in res) {
    print('Package: ${vul['package_name']}');
    print('Package Manager: ${vul['package_manager']}');
    print('Vulnerability id: ${vul['id']}');
    print('Summary: ${vul['summary']}');
    print('Description:\n');
    print('${vul['description']}\n');
  }
}

void onInvalidInput(String error) {
  print('Invalid result format, $error');
  exit(5);
}
