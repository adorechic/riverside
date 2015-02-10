class EntriesControllerStylesheet < ApplicationStylesheet
  def entry_title(st)
    st.frame = { l: 0, below_prev: 0, w: device_width, h: 60 }
    st.color = color.battleship_gray
    st.font = font.medium
  end

  def entry_body(st)
    st.frame = { l: 0, below_prev: 0, w: device_width, h: 800 }
  end

  def root_view(st)
  end
end
