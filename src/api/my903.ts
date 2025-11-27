import request from '@/api/request';

export function getMy903List({pageNo=1, pageSize=10,tag=''}={}) {
  return request({
    url: '/my903/list',
    method: 'get',
    params: {
      page:pageNo,
      limit:pageSize,
      tag, //9
    }
  });
}


export function getSyncInfoApi(id) {
  return request({
    url: `/my903/sync-info`,
    method: 'get',
  });
}

export function fetchNewApi() {
    return request({
    url: `/tasks/fetchNew`,
    method: 'get',
  });
}

export function getDetailApi(id) {
  return request({
    url: `/my903/detail/${id}`,
    method: 'get',
  });
}
