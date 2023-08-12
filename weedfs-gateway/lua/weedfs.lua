local http = require "resty.http"
local cjson = require "cjson"
local resty_sha256 = require "resty.sha256"

local weedfs = {}

function weedfs:put(put_url,put_fid)
    
    local res = ngx.location.capture(
        "/weedfs/_put", {method = ngx.HTTP_PUT,args={fid=put_fid, url=put_url},share_all_vars = true}
        )

    return res.status , res.body
end

function weedfs:delete(del_fid)
    local res = ngx.location.capture(
        "/weedfs/_delete", {method = ngx.HTTP_DELETE,args={fid=del_fid},share_all_vars = true}
        )
    return res.status , res.body
end

function weedfs:assing()
    local hc = http.new()
    ngx.log(ngx.INFO,"weedfs assign:",ngx.var.weed_img_root_url .. "dir/assign")
    local res,err = hc:request_uri(ngx.var.weed_img_root_url .. "dir/assign")
    if not res then
      ngx.log(ngx.ERR,"weedfs assign error:",err)
    end
    return res.status , res.body
end

function weedfs:lookup(volume_id)
    local hc = http.new()
    ngx.log(ngx.INFO,"weedfs lookup:",ngx.var.weed_img_root_url .. "dir/assign")
    local res,err = hc:request_uri(ngx.var.weed_img_root_url .. "dir/lookup?volumeId="..volume_id)
    if not res then
      ngx.log(ngx.ERR,"weedfs lookup error:",err)
    end
    return res.status , res.body
end

function weedfs:upload()
  local code , body = self:assing()
  if code ~= 200 then
    return code, body
  else
    local assing_info = cjson.decode(body)
    ngx.req.read_body()
    local body_data = ngx.req.get_body_data()
    if body_data then    
      local sha256 = resty_sha256:new()
      sha256:update(body_data)
      local digest = sha256:final()
      local sha256_hash = ngx.encode_base64(digest)
      assing_info.sha256 = sha256_hash
    end   
    local put_code, put_body = weedfs:put(assing_info.publicUrl,assing_info.fid);
    if put_code ~= 201 then
      return put_code, put_body
    else
      local result_info = cjson.decode(put_body)
      result_info.fid = assing_info.fid
      return put_code, result_info
    end
  end
end

return weedfs