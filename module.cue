package cue_k8s_module

import (
	"list"
	"strings"
	"encoding/yaml"
	meta "cue.dev/x/k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Defines a Kubernetes deployment unit with automatic metadata generation, nested module composition, and Helm chart integration.
#Module: {
	// Base identifier for this module (e.g., "nginx", "database").
	name: string

	// Ancestor module names, used to build hierarchical naming prefixes.
	// Each is automatically inherited by nested modules.
	parentNames: [...string] | *[]

	// Optional instance identifier for deploying multiple independent instances of the same module (e.g., "primary", "replica").
	// Included in both resource names and app.kubernetes.io/instance label when specified.
	instance?: string

	// Kubernetes namespace where objects are deployed.
	namespace: string

	// Application version, included as app.kubernetes.io/version label if specified.
	version?: string

	// Kubernetes object metadata with auto-generated name, namespace, and labels.
	// Includes app name hierarchy and optional version and instance identifiers.
	// All contained objects automatically inherit this metadata.
	metadata: meta.#ObjectMeta & (_ | *{
		"name":      _ | *strings.Join(_nameComponents, "-")
		"namespace": _ | *namespace
		"labels": _ | *{
			"app.kubernetes.io/name": _ | *_allNames[0]
			if len(_allNames) > 1 {
				"app.kubernetes.io/component": _ | *strings.Join(list.Drop(_allNames, 1), "-")
			}
			if version != _|_ {
				"app.kubernetes.io/version": _ | *version
			}
			if instance != _|_ {
				"app.kubernetes.io/instance": _ | *instance
			}
		}
	})

	// Computed resource name components: instance (if set) followed by module names.
	// Avoids duplication when instance name starts with module name.
	_nameComponents: [
		if instance != _|_ {instance},
		for i, n in _allNames
		if *!(i == 0 && strings.HasPrefix(instance, n)) | true {n},
	]

	// Full hierarchy of all module names from ancestors to current level.
	_allNames: list.Concat([parentNames, [name]])

	// Kubernetes objects keyed by logical identifier.
	// Each object inherits this module's metadata.
	// The "all" key is reserved for aggregation.
	objects: [string & !="all"]: {
		"metadata": metadata
		...
	}

	// Aggregated collection of all objects: direct module objects, nested module objects (recursively), and transformed Helm chart outputs.
	// Used for rendering all resources to output.
	objects: all: [
		for k, v in objects if k != "all" {
			v
		},
		for _, m in modules for _, o in m.objects.all {
			o
		},
		for _, chart in helm for _, o in chart.transformed {
			o
		},
	]

	// Child modules that inherit parent naming, namespace, and instance settings.
	// Each nested module receives this module's name as part of its naming hierarchy.
	modules: [string]: #Module & {
		parentNames: _allNames
		if instance != _|_ {
			"instance": instance
		}
		"namespace": namespace
		if version != _|_ {
			"version": version
		}
	}

	// Helm charts indexed by key.
	// Each chart is rendered and its output objects are aggregated into objects.all.
	helm: [key=string]: {
		// Optional repository for classic Helm charts.
		repo?: string

		// OCI registry path or traditional Helm repository URL
		chart: string

		// Semantic version string for chart selection
		version: string

		// Release name in cluster (defaults to key name if omitted)
		releaseName: string | *key

		// Helm values passed to chart rendering
		values: {...}

		// Helm template output rendered from the chart and values
		rendered: {
			raw = "yaml": string
			objects:      yaml.UnmarshalStream(raw)
		}

		// Chart output objects that can be customized for post-processing.
		// Defaults to rendered objects if not overridden.
		transformed: [...{...}] | *rendered.objects
	}

	...
}
