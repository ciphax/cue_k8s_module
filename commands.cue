package cue_k8s_module

import (
	"list"
	"encoding/yaml"
	"tool/cli"
	"tool/exec"
	"tool/os"
)

#Commands: {
	#module: #Module

	render: {
		getEnv: os.Getenv & {
			NAMESPACE:            string
			ARGOCD_APP_NAMESPACE: string
			MODULE: string | *yaml.Marshal({})
			PARAM_MODULE: string | *yaml.Marshal({})
		}
		_withInputs: #module &
			yaml.Unmarshal(getEnv.MODULE) &
			yaml.Unmarshal(getEnv.PARAM_MODULE) & {
				namespace: getEnv.NAMESPACE & getEnv.ARGOCD_APP_NAMESPACE
			}
		renderHelmCharts: {
			for key, config in _withInputs.helm {
				(key): exec.Run & {
					cmd: list.Concat([
						["helm", "template"],
						[config.releaseName],
						if config.repo != _|_ {
							["--repo", config.repo]
						},
						[config.chart],
						["--version", config.version],
						["-f", "-"],
					])
					stdout: string
					stdin:  yaml.Marshal(config.values)
					$after: [getEnv]
				}
			}
		}
		_withRenderedHelmCharts: (_withInputs & {"helm": {
			for key, result in renderHelmCharts {
				(key): rendered: yaml: result.stdout
			}
		}})
		printObjects: cli.Print & {
			text: yaml.MarshalStream(_withRenderedHelmCharts.objects.all)
		}
	}
}
