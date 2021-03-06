#     using MAT

    struct NCSSeg
        qwTimeStamp::UInt64
        dwChannelNumber::UInt32
        dwSampleFreq::UInt32
        dwNumValidSamples::UInt32
        snSample::Array{Int16,1}
    end

    struct NCSData
        filename::String
        header::String
        seg_num::UInt32
        data::Array{NCSSeg, 1}
        sample::Array{Int16, 1}
    end

    # read neuralynx file
    function readNCSFile(filename)

        f = open(filename)
        header = read(f, UInt8, 16*1024) .|> Char |> String
        bdata = reinterpret(Int16, read(f))
        close(f)


        records = length(bdata) / 522 |> Int
        data = Array{NCSSeg, 1}(records)

        for i = 1:records
            segdata = bdata[1+(i-1)*522:522*i]

            timestamp = reinterpret(UInt64, segdata[1:4])
            chnum = reinterpret(UInt32, segdata[5:6])
            samplefreq = reinterpret(UInt32, segdata[7:8])
            samplenum = reinterpret(UInt32, segdata[9:10])

            data[i] = NCSSeg(timestamp[1], chnum[1], samplefreq[1], samplenum[1], segdata[11:522])
        end

        sample = zeros(Int16, records*512)
        for idx = 1:records
            sample[1+512*(idx-1):512*idx] = data[idx].snSample
        end

        return NCSData(filename, header, records, data, sample)
    end

    # # save into mat-v7.3 file
    # function save(filename::String, ncs::NCSData; mode=:sampleonly)
    #
    #     if mode == :sampleonly
    #         matwrite(filename, Dict("header"=>ncs.header, "sample"=>ncs.sample))
    #     elseif mode == :all
    #         matwrite(filename,
    #             Dict("header"=>ncs.header,
    #                 "seg_num"=>ncs.seg_num,
    #                 "data"=>ncs.data,
    #                 "sample"=>ncs.sample))
    #     else
    #         matwrite(filename, Dict("header"=>ncs.header, "sample"=>ncs.sample))
    #     end
    # end
