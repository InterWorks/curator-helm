module.exports = {
  branches: ['main'],
  repositoryUrl: 'https://github.com/interworks/curator-helm',
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/github',
    [
      '@semantic-release/exec',
      {
        "prepare": "yq eval '.version = \"${nextRelease.version}\"' -i Chart.yaml"
      },
    ]
  ],
};