import Tov from './presets'
import { defineConfig } from 'vite'
import path from 'path'
import { useEnv } from './presets/shared/detect'
const env = useEnv()

const prefixPath = env.VITE_APP_PREFIX

export default defineConfig({
	plugins: [Tov()],
		base: prefixPath,

	resolve: {
		alias: {
			'@': path.resolve(__dirname, 'src'),
		},
	},
	css: {
		preprocessorOptions: {
			less: {
				javascriptEnabled: true,
			},
		},
	},
	server: {
		port: 5174,
		host: '0.0.0.0',
		proxy: {
			'/dev': {
				target: 'http://127.0.0.1:6090',
				changeOrigin: true,
				rewrite: (path) => path.replace(/^\/dev/, ''),
			},
		},
	},
})
