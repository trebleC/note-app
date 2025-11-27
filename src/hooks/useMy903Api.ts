const dataList = ref([])

async function useMy903Api(params) {
   
}

export default async (params) => {
    const {data} = await getMy903List(params)
    return data
}

// export {
//     dataList
// }