<script lang="ts">
	import { getContext, tick } from 'svelte';
	import { toast } from 'svelte-sonner';
	import { models, settings, user } from '$lib/stores';
	import { updateUserSettings } from '$lib/apis/users';
	import { getModels as _getModels } from '$lib/apis';
	import { goto } from '$app/navigation';

	import Modal from '../common/Modal.svelte';
	import General from './Settings/General.svelte';

	const i18n = getContext('i18n');

	export let show = false;

	interface SettingsTab {
		id: string;
		title: string;
		keywords: string[];
	}

	const searchData: SettingsTab[] = [
		{
			id: 'general',
			title: 'General',
			keywords: [
				'general',
				'theme',
				'language',
				'notifications',
				'system',
				'systemprompt',
				'prompt',
				'advanced',
				'settings',
				'defaultsettings',
				'configuration',
				'systemsettings',
				'notificationsettings',
				'systempromptconfig',
				'languageoptions',
				'defaultparameters',
				'systemparameters'
			]
		},
		{
			id: 'interface',
			title: 'Interface',
			keywords: [
				'defaultmodel',
				'selectmodel',
				'ui',
				'userinterface',
				'display',
				'layout',
				'design',
				'landingpage',
				'landingpagemode',
				'default',
				'chat',
				'chatbubble',
				'chatui',
				'username',
				'showusername',
				'displayusername',
				'widescreen',
				'widescreenmode',
				'fullscreen',
				'expandmode',
				'chatdirection',
				'lefttoright',
				'ltr',
				'righttoleft',
				'rtl',
				'notifications',
				'toast',
				'toastnotifications',
				'largechunks',
				'streamlargechunks',
				'scroll',
				'scrollonbranchchange',
				'scrollbehavior',
				'richtext',
				'richtextinput',
				'background',
				'chatbackground',
				'chatbackgroundimage',
				'backgroundimage',
				'uploadbackground',
				'resetbackground',
				'titleautogen',
				'titleautogeneration',
				'autotitle',
				'chattags',
				'autochattags',
				'responseautocopy',
				'clipboard',
				'location',
				'userlocation',
				'userlocationaccess',
				'haptic',
				'hapticfeedback',
				'vibration',
				'voice',
				'voicecontrol',
				'voiceinterruption',
				'call',
				'emojis',
				'displayemoji',
				'save',
				'interfaceoptions',
				'interfacecustomization'
			]
		},
		{
			id: 'personalization',
			title: 'Personalization',
			keywords: [
				'personalization',
				'memory',
				'personalize',
				'preferences',
				'profile',
				'personalsettings',
				'customsettings',
				'userpreferences',
				'accountpreferences'
			]
		},
		{
			id: 'audio',
			title: 'Audio',
			keywords: [
				'audio',
				'sound',
				'soundsettings',
				'audiocontrol',
				'volume',
				'speech',
				'speechrecognition',
				'stt',
				'speechtotext',
				'tts',
				'texttospeech',
				'playback',
				'playbackspeed',
				'voiceplayback',
				'speechplayback',
				'audiooutput',
				'speechengine',
				'voicecontrol',
				'audioplayback',
				'transcription',
				'autotranscribe',
				'autosend',
				'speechsettings',
				'audiovoice',
				'voiceoptions',
				'setvoice',
				'nonlocalvoices',
				'savesettings',
				'audioconfig',
				'speechconfig',
				'voicerecognition',
				'speechsynthesis',
				'speechmode',
				'voicespeed',
				'speechrate',
				'speechspeed',
				'audioinput',
				'audiofeatures',
				'voicemodes'
			]
		},
		{
			id: 'chats',
			title: 'Chats',
			keywords: [
				'chat',
				'messages',
				'conversations',
				'chatsettings',
				'history',
				'chathistory',
				'messagehistory',
				'messagearchive',
				'convo',
				'chats',
				'conversationhistory',
				'exportmessages',
				'chatactivity'
			]
		},
		{
			id: 'account',
			title: 'Account',
			keywords: [
				'account',
				'profile',
				'security',
				'privacy',
				'settings',
				'login',
				'useraccount',
				'userdata',
				'api',
				'apikey',
				'userprofile',
				'profiledetails',
				'accountsettings',
				'accountpreferences',
				'securitysettings',
				'privacysettings'
			]
		},
		{
			id: 'admin',
			title: 'Admin',
			keywords: [
				'admin',
				'administrator',
				'adminsettings',
				'adminpanel',
				'systemadmin',
				'administratoraccess',
				'systemcontrol',
				'manage',
				'management',
				'admincontrols',
				'adminfeatures',
				'usercontrol',
				'arenamodel',
				'evaluations',
				'websearch',
				'database',
				'pipelines',
				'images',
				'audio',
				'documents',
				'rag',
				'models',
				'ollama',
				'openai',
				'users'
			]
		},
		{
			id: 'about',
			title: 'About',
			keywords: [
				'about',
				'info',
				'information',
				'version',
				'documentation',
				'help',
				'support',
				'details',
				'aboutus',
				'softwareinfo',
				'timothyjaeryangbaek',
				'openwebui',
				'release',
				'updates',
				'updateinfo',
				'versioninfo',
				'aboutapp',
				'terms',
				'termsandconditions',
				'contact',
				'aboutpage'
			]
		}
	];

	let search = '';
	let visibleTabs = searchData.map((tab) => tab.id);
	let searchDebounceTimeout;

	const searchSettings = (query: string): string[] => {
		const lowerCaseQuery = query.toLowerCase().trim();
		return searchData
			.filter(
				(tab) =>
					tab.title.toLowerCase().includes(lowerCaseQuery) ||
					tab.keywords.some((keyword) => keyword.includes(lowerCaseQuery))
			)
			.map((tab) => tab.id);
	};

	const searchDebounceHandler = () => {
		clearTimeout(searchDebounceTimeout);
		searchDebounceTimeout = setTimeout(() => {
			visibleTabs = searchSettings(search);
			if (visibleTabs.length > 0 && !visibleTabs.includes(selectedTab)) {
				selectedTab = visibleTabs[0];
			}
		}, 100);
	};

	const saveSettings = async (updated) => {
		console.log(updated);
		await settings.set({ ...$settings, ...updated });
		await models.set(await getModels());
		await updateUserSettings(localStorage.token, { ui: $settings });
	};

	const getModels = async () => {
		return await _getModels(localStorage.token);
	};

	let selectedTab = 'general';

	// Function to handle sideways scrolling
	const scrollHandler = (event) => {
		const settingsTabsContainer = document.getElementById('settings-tabs-container');
		if (settingsTabsContainer) {
			event.preventDefault(); // Prevent default vertical scrolling
			settingsTabsContainer.scrollLeft += event.deltaY; // Scroll sideways
		}
	};

	const addScrollListener = async () => {
		await tick();
		const settingsTabsContainer = document.getElementById('settings-tabs-container');
		if (settingsTabsContainer) {
			settingsTabsContainer.addEventListener('wheel', scrollHandler);
		}
	};

	const removeScrollListener = async () => {
		await tick();
		const settingsTabsContainer = document.getElementById('settings-tabs-container');
		if (settingsTabsContainer) {
			settingsTabsContainer.removeEventListener('wheel', scrollHandler);
		}
	};

	$: if (show) {
		addScrollListener();
	} else {
		removeScrollListener();
	}
</script>

<Modal size="xl" bind:show>
	<div class="text-gray-700 dark:text-gray-100">
		<div class=" flex justify-between dark:text-gray-300 px-5 pt-4 pb-1">
			<div class=" text-lg font-medium self-center">{$i18n.t('Settings')}</div>
			<button
				class="self-center"
				on:click={() => {
					show = false;
				}}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 20 20"
					fill="currentColor"
					class="w-5 h-5"
				>
					<path
						d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"
					/>
				</svg>
			</button>
		</div>

		<div class="flex flex-col md:flex-row w-full px-4 pt-1 pb-4 md:space-x-4">
			<div
				id="settings-tabs-container"
				class="tabs flex flex-row overflow-x-auto gap-2.5 md:gap-1 md:flex-col flex-1 md:flex-none md:w-40 dark:text-gray-200 text-sm font-medium text-left mb-1 md:mb-0 -translate-y-1"
			>
				<div class="hidden md:flex w-full rounded-xl -mb-1 px-0.5 gap-2" id="settings-search">
					<div class="self-center rounded-l-xl bg-transparent">
						<Search className="size-3.5" />
					</div>
					<div class=" self-center">{$i18n.t('General')}</div>
				</button>
			</div>
			<div class="flex-1">
				<General
					{saveSettings}
					on:save={() => {
						toast.success($i18n.t('Settings saved successfully!'));
					}}
				/>
			</div>
		</div>
	</div>
</Modal>

<style>
	input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button {
		/* display: none; <- Crashes Chrome on hover */
		-webkit-appearance: none;
		margin: 0; /* <-- Apparently some margin are still there even though it's hidden */
	}

	.tabs::-webkit-scrollbar {
		display: none; /* for Chrome, Safari and Opera */
	}

	.tabs {
		-ms-overflow-style: none; /* IE and Edge */
		scrollbar-width: none; /* Firefox */
	}

	input[type='number'] {
		-moz-appearance: textfield; /* Firefox */
	}
</style>
