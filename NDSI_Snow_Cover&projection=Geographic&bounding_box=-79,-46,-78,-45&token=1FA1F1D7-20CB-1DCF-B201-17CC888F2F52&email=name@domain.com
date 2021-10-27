<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<eesi:Exception xmlns="" xmlns:iesi="http://eosdis.nasa.gov/esi/rsp/i" xmlns:ssw="http://newsroom.gsfc.nasa.gov/esi/rsp/ssw" xmlns:eesi="http://eosdis.nasa.gov/esi/rsp/e" xmlns:esi="http://eosdis.nasa.gov/esi/rsp" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Code>InternalError</Code>
    <Message>No granules returned by CMR: https://cmr.earthdata.nasa.gov/search/granules?bounding_box=-79,-46,-78,-45&amp;provider=NSIDC_ECS&amp;short_name=MYD10A1&amp;version=6&amp;temporal=2000-02-25,2000-02-26&amp;token=1FA1F1D7-20CB-1DCF-B201-17CC888F2F52</Message>
</eesi:Exception>
