#!/usr/bin/env node
import glob from 'fast-glob'
import fsp from 'fs/promises'
import _ from 'lodash'
import path from 'path'
import { replaceInFile } from 'replace-in-file'
import { pkgsDirJoin } from '../utils'
import admob from './admob'
import consent from './consent'
import { indent4 } from './shared'

async function updateConfigXML({
  pkgDir,
  tagertDir,
}: {
  pkgDir: string
  tagertDir: string
}) {
  const [androidFiles, iosFiles] = await Promise.all([
    glob(['**/*.java'], {
      cwd: path.join(pkgDir, 'src/android'),
    }),
    glob(['*.swift'], {
      cwd: path.join(pkgDir, 'src/ios'),
    }),
  ])
  const androidContent = androidFiles
    .map((s) => {
      const d = path.join(tagertDir, path.dirname(s.toString()))
      return `${indent4(
        2,
      )}<source-file src="src/android/${s}" target-dir="${d}" />`
    })
    .sort()
    .join('\n')
  const iosContent = iosFiles
    .map((s) => `${indent4(2)}<source-file src="src/ios/${s}" />`)
    .sort()
    .join('\n')

  await replaceInFile({
    files: [path.join(pkgDir, 'plugin.xml')],
    from: /([\S\s]*ANDROID_BEGIN -->\n)[\S\s]*(\n\s+<!-- AUTOGENERATED: ANDROID_END[\S\s]*IOS_BEGIN -->\n)[\S\s]*(\n\s+<!-- AUTOGENERATED: IOS_END[\S\s]*)/,
    to: `$1${androidContent}$2${iosContent}$3`,
  })
}

async function main() {
  const specs = await Promise.all([admob, consent].map((f) => f()))

  await Promise.all(
    _.flatMap(specs, ({ files }) => files).map((x) =>
      fsp.writeFile(pkgsDirJoin(x.path), x.f(), 'utf8'),
    ),
  )

  await Promise.all(specs.map(updateConfigXML))
}

main()