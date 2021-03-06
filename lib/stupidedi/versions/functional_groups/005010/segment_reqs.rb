module Stupidedi
  using Refinements

  module Versions
    module FunctionalGroups
      module FiftyTen

        #
        # @see X222.pdf B.1.1.3.9 Condition Designator
        # @see X222.pdf B.1.1.3.12.6 Data Segment Requirement Designator
        #
        module SegmentReqs
          Mandatory = Schema::SegmentReq.new(true,  false, "M")
          Optional  = Schema::SegmentReq.new(false, false, "O")
        end

      end
    end
  end
end
