<template>
    <div v-if="visible" class="fixed inset-0 bg-black/90 z-50 flex items-center justify-center image-reviewer"
        @click.self="closeViewer">
        <div class="container mx-auto h-full flex flex-col md:flex-row max-w-7xl">
            <!-- 左侧/顶部图片区域 -->
            <div class="flex-1 flex items-center justify-center relative p-4 md:p-8 min-h-[40vh] md:min-h-0">
                <!-- 关闭按钮 -->
                <button @click="closeViewer"
                    class="absolute top-2 right-2 md:top-6 md:right-6 text-white text-2xl md:text-3xl hover:text-gray-300 transition-colors z-10 w-10 h-10 flex items-center justify-center">
                    <i class="fa fa-times"></i>
                </button>

                <!-- 图片容器 -->
                <div class="relative w-full h-full flex items-center justify-center">
                    <img :src="currentImage" :alt="imageData.title" class="max-w-full max-h-full object-contain">

                    <!-- 上一张按钮 -->
                    <button v-if="hasPrevious" @click="previousImage"
                        class="absolute left-2 md:left-4 top-1/2 -translate-y-1/2 bg-black/50 hover:bg-black/70 text-white w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center transition-colors">
                        <i class="fa fa-chevron-left"></i>
                    </button>

                    <!-- 下一张按钮 -->
                    <button v-if="hasNext" @click="nextImage"
                        class="absolute right-2 md:right-4 top-1/2 -translate-y-1/2 bg-black/50 hover:bg-black/70 text-white w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center transition-colors">
                        <i class="fa fa-chevron-right"></i>
                    </button>

                    <!-- 图片指示器 -->
                    <div v-if="images.length > 1"
                        class="absolute bottom-2 md:bottom-4 left-1/2 -translate-x-1/2 bg-black/50 px-3 md:px-4 py-1 md:py-2 rounded-full text-white text-xs md:text-sm">
                        {{ currentIndex + 1 }} / {{ images.length }}
                    </div>
                </div>
            </div>

            <!-- 右侧/底部详情区域 -->
            <div class="w-full md:w-96 bg-white flex flex-col max-h-[60vh] md:max-h-full">
                <!-- 头部信息 -->
                <div class="p-4 md:p-4 border-b border-gray-200">
                    <!-- <div class="flex items-center gap-2 md:gap-3 mb-3 md:mb-4">
                        <div
                            class="w-10 h-10 md:w-12 md:h-12 bg-primary rounded-full flex items-center justify-center text-white font-bold text-sm md:text-base">
                            {{ getInitial(imageData.author || '用户') }}
                        </div>
                        <div class="flex-1 min-w-0">
                            <div class="font-semibold text-gray-900 text-sm md:text-base truncate">{{ imageData.author
                                || '匿名用户' }}</div>
                            <div class="text-xs md:text-sm text-gray-500">{{ imageData.create_date }}</div>
                        </div>
                        <button
                            class="text-primary hover:text-primary/80 transition-colors text-sm md:text-base flex items-center gap-1 whitespace-nowrap">
                            <i class="fa fa-user-plus"></i> <span class="hidden sm:inline">关注</span>
                        </button>
                    </div> -->

                    <!-- 标题 -->
                    <h2 class="text-lg md:text-xl font-bold text-gray-900 mb-2">{{ imageData.title }}</h2>
                    <div class="text-xs md:text-sm text-gray-500">{{ imageData.create_date }}</div>
                </div>

                <!-- 内容区域 - 可滚动 -->
                <div class="flex-1 overflow-y-auto p-4 md:p-6">
                    <!-- 创作者信息 -->
                    <div v-if="hasCreatorInfo" class="mb-4 md:mb-6 space-y-1 text-sm md:text-base">
                        <div v-if="imageData.composer_list" class="flex items-start gap-2">
                            <span class="text-gray-500 font-medium whitespace-nowrap">🔗 曲：</span>
                            <span class="text-gray-700">{{ formatCreatorList(imageData.composer_list) }}</span>
                        </div>
                        <div v-if="imageData.lyricist_list" class="flex items-start gap-2">
                            <span class="text-gray-500 font-medium whitespace-nowrap">🔗 詞：</span>
                            <span class="text-gray-700">{{ formatCreatorList(imageData.lyricist_list) }}</span>
                        </div>
                        <div v-if="imageData.arranger_list" class="flex items-start gap-2">
                            <span class="text-gray-500 font-medium whitespace-nowrap">🔗 編：</span>
                            <span class="text-gray-700">{{ formatCreatorList(imageData.arranger_list) }}</span>
                        </div>
                        <div v-if="imageData.producer_list" class="flex items-start gap-2">
                            <span class="text-gray-500 font-medium whitespace-nowrap">🔗 監：</span>
                            <span class="text-gray-700">{{ formatCreatorList(imageData.producer_list) }}</span>
                        </div>
                    </div>

                    <!-- 描述 -->
                     
                    <div class="text-gray-700 leading-relaxed mb-4 md:mb-6 text-sm md:text-base">
                        <div v-html="imageData.description || '暂无描述' "></div>
                    </div>

                    <!-- 标签 -->
                    <div v-if="imageData.tags && imageData.tags.length" class="flex flex-wrap gap-2 mb-4 md:mb-6">
                        <span v-for="tag in imageData.tags" :key="tag"
                            class="px-2 md:px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs md:text-sm hover:bg-gray-200 cursor-pointer transition-colors">
                            #{{ tag }}
                        </span>
                    </div>

                    <!-- 统计信息 -->
                    <div
                        class="flex items-center gap-3 md:gap-6 py-3 md:py-4 border-t border-b border-gray-200 mb-4 md:mb-6">
                        <div class="flex items-center gap-1 md:gap-2 text-gray-600 text-xs md:text-sm">
                            <i class="fa fa-eye"></i>
                            <span>{{ formatNumber(imageData.views || 0) }}</span>
                        </div>
                        <div class="flex items-center gap-1 md:gap-2 text-gray-600 text-xs md:text-sm">
                            <i class="fa fa-heart-o"></i>
                            <span>{{ formatNumber(imageData.likes || 0) }}</span>
                        </div>
                        <div class="flex items-center gap-1 md:gap-2 text-gray-600 text-xs md:text-sm">
                            <i class="fa fa-bookmark-o"></i>
                            <span>{{ formatNumber(imageData.collects || 0) }}</span>
                        </div>
                    </div>

                    <!-- 评论区域 -->
                    <div class="mb-4">
                        <h3 class="font-semibold text-gray-900 mb-3 md:mb-4 text-sm md:text-base">评论 ({{ comments.length
                        }})</h3>
                        <div v-if="comments.length === 0"
                            class="text-center text-gray-400 py-6 md:py-8 text-sm md:text-base">
                            暂无评论，快来抢沙发~
                        </div>
                        <div v-else class="space-y-3 md:space-y-4">
                            <div v-for="comment in comments" :key="comment.id" class="flex gap-2 md:gap-3">
                                <div
                                    class="w-7 h-7 md:w-8 md:h-8 bg-gray-300 rounded-full flex items-center justify-center text-white text-xs flex-shrink-0">
                                    {{ getInitial(comment.author) }}
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="font-medium text-xs md:text-sm text-gray-900">{{ comment.author }}</div>
                                    <div class="text-xs md:text-sm text-gray-700 mt-1 break-words">{{ comment.content }}
                                    </div>
                                    <div class="text-xs text-gray-500 mt-1">{{ comment.time }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 底部操作栏 -->
                <div class="p-3 md:p-4 border-t border-gray-200 bg-gray-50" v-if="0">
                    <div class="flex items-center gap-2 md:gap-4 mb-2 md:mb-3">
                        <button @click="toggleLike"
                            class="flex-1 flex items-center justify-center gap-1 md:gap-2 py-2 rounded-lg transition-colors text-xs md:text-sm"
                            :class="isLiked ? 'bg-red-50 text-red-500' : 'bg-white text-gray-700 hover:bg-gray-100'">
                            <i :class="isLiked ? 'fa fa-heart' : 'fa fa-heart-o'"></i>
                            <span class="hidden sm:inline">{{ isLiked ? '已点赞' : '点赞' }}</span>
                        </button>
                        <button @click="toggleBookmark"
                            class="flex-1 flex items-center justify-center gap-1 md:gap-2 py-2 rounded-lg transition-colors text-xs md:text-sm"
                            :class="isBookmarked ? 'bg-primary/10 text-primary' : 'bg-white text-gray-700 hover:bg-gray-100'">
                            <i :class="isBookmarked ? 'fa fa-bookmark' : 'fa fa-bookmark-o'"></i>
                            <span class="hidden sm:inline">{{ isBookmarked ? '已收藏' : '收藏' }}</span>
                        </button>
                        <button
                            class="flex-1 flex items-center justify-center gap-1 md:gap-2 py-2 bg-white text-gray-700 hover:bg-gray-100 rounded-lg transition-colors text-xs md:text-sm">
                            <i class="fa fa-share-alt"></i>
                            <span class="hidden sm:inline">分享</span>
                        </button>
                    </div>

                    <!-- 评论输入框 -->
                    <div class="flex gap-2">
                        <input v-model="commentInput" type="text" placeholder="说点什么..."
                            class="flex-1 px-3 md:px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/50 text-sm md:text-base"
                            @keyup.enter="submitComment">
                        <button @click="submitComment"
                            class="px-4 md:px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors text-sm md:text-base whitespace-nowrap">
                            发送
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue';

const props = defineProps({
    visible: {
        type: Boolean,
        default: false
    },
    imageData: {
        type: Object,
        default: () => ({
            cover: "",
            id: "",
            name: "",
            description: "",
            singer_list: [],
            composer_list: [],
            arranger_list: [],
            lyricist_list: [],
            producer_list: [],
            youtube_media: {},

            title: '',
            desc: '',
            author: '',
            create_date: '',
            images: [],
            tags: [],
            views: 0,
            likes: 0,
            collects: 0
        })
    }
});

const emit = defineEmits(['close', 'update:visible']);

// 状态
const currentIndex = ref(0);
const isLiked = ref(false);
const isBookmarked = ref(false);
const commentInput = ref('');
const comments = ref([]);

// 图片数组
const images = computed(() => {
    if (props.imageData.images && props.imageData.images.length > 0) {
        return props.imageData.images;
    }
    return props.imageData.cover ? [props.imageData.cover] : [];
});

// 当前图片
const currentImage = computed(() => {
    return images.value[currentIndex.value] || '';
});

// 是否有上一张
const hasPrevious = computed(() => currentIndex.value > 0);

// 是否有下一张
const hasNext = computed(() => currentIndex.value < images.value.length - 1);

// 是否有创作者信息
const hasCreatorInfo = computed(() => {
    return props.imageData.composer_list || 
           props.imageData.lyricist_list || 
           props.imageData.arranger_list || 
           props.imageData.producer_list;
});

// 上一张
const previousImage = () => {
    if (hasPrevious.value) {
        currentIndex.value--;
    }
};

// 下一张
const nextImage = () => {
    if (hasNext.value) {
        currentIndex.value++;
    }
};

// 关闭查看器
const closeViewer = () => {
    emit('update:visible', false);
    emit('close');
    currentIndex.value = 0;
};

// 切换点赞
const toggleLike = () => {
    isLiked.value = !isLiked.value;
};

// 切换收藏
const toggleBookmark = () => {
    isBookmarked.value = !isBookmarked.value;
};

// 提交评论
const submitComment = () => {
    if (!commentInput.value.trim()) return;

    comments.value.unshift({
        id: Date.now(),
        author: '当前用户',
        content: commentInput.value,
        time: '刚刚'
    });

    commentInput.value = '';
};

// 获取用户名首字母
const getInitial = (name) => {
    return name ? name.charAt(0).toUpperCase() : 'U';
};

// 格式化数字
const formatNumber = (num) => {
    if (num >= 10000) {
        return (num / 10000).toFixed(1) + 'w';
    }
    return num;
};

// 格式化创作者列表
const formatCreatorList = (list) => {
    if (!list) return '';
    // 将逗号、分号等分隔符统一替换为顿号
    return list.join('、');
};

// 键盘事件
const handleKeydown = (e) => {
    if (!props.visible) return;

    if (e.key === 'Escape') {
        closeViewer();
    } else if (e.key === 'ArrowLeft') {
        previousImage();
    } else if (e.key === 'ArrowRight') {
        nextImage();
    }
};

// 监听 visible 变化
watch(() => props.visible, (newVal) => {
    if (newVal) {
        document.addEventListener('keydown', handleKeydown);
        document.body.style.overflow = 'hidden';
    } else {
        document.removeEventListener('keydown', handleKeydown);
        document.body.style.overflow = '';
    }
});
</script>

<style scoped>
/* 滚动条样式 */
.overflow-y-auto::-webkit-scrollbar {
    width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
    background-color: rgba(0, 0, 0, 0.3);
}

.overflow-y-auto::-webkit-scrollbar-track {
    background-color: transparent;
}
</style>
