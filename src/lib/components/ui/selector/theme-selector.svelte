<script lang="ts">
	import * as Select from '$lib/components/ui/select/index.js';
	import { browser } from '$app/environment';
	import { onMount } from 'svelte';

	const themes = ['latte', 'frappe', 'macchiato', 'mocha'] as const;
	type Theme = (typeof themes)[number];
	let selectedTheme = $state<Theme>('latte');
	let hydrated = $state(false);

	const themeEmojis: Record<Theme, string> = {
		latte: '🌻',
		frappe: '🪴',
		macchiato: '🌺',
		mocha: '🌿'
	};

	function toTitle(t: Theme): string {
		if (t === 'frappe') return 'Frappé';
		return t.charAt(0).toUpperCase() + t.slice(1);
	}

	function applyTheme(theme: Theme) {
		if (!browser) return;
		const root = document.documentElement;
		for (const t of themes) root.classList.remove('theme-' + t);
		root.classList.add('theme-' + theme);
		const isDark = theme === 'frappe' || theme === 'macchiato' || theme === 'mocha';
		root.classList.toggle('dark', isDark);
		localStorage.setItem('theme', theme);
	}

	onMount(() => {
		if (!browser) return;
		hydrated = true;
		const stored = localStorage.getItem('theme');
		if (stored && themes.includes(stored as Theme)) {
			selectedTheme = stored as Theme;
		}
		applyTheme(selectedTheme);
	});

	function handleThemeChange(value: string | undefined) {
		if (!value) return;
		if (themes.includes(value as Theme)) {
			selectedTheme = value as Theme;
			applyTheme(selectedTheme);
		}
	}
</script>

<Select.Root type="single" value={selectedTheme} onValueChange={handleThemeChange}>
	<Select.Trigger class="flex h-8 w-20 items-center gap-2">
		<span
			class="inline-flex h-4 w-4 items-center justify-center text-base leading-none"
			style="font-variant-emoji: emoji; visibility: {hydrated ? 'visible' : 'hidden'};"
		>
			{themeEmojis[selectedTheme]}
		</span>
	</Select.Trigger>
	<Select.Content>
		<Select.Group>
			{#each themes as t}
				<Select.Item value={t}>
					<div class="flex items-center gap-2">
						<span
							class="inline-flex h-4 w-4 items-center justify-center text-base leading-none"
							style="font-variant-emoji: emoji;"
						>
							{themeEmojis[t]}
						</span>
						<span>{toTitle(t)}</span>
					</div>
				</Select.Item>
			{/each}
		</Select.Group>
	</Select.Content>
</Select.Root>
